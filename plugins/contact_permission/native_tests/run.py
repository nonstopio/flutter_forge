#!/usr/bin/env python3
"""Compile native production sources against deterministic SDK boundary fakes."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent
PLUGIN = HERE.parent
OUTPUT = HERE / 'coverage'


def run(command, cwd=HERE, env=None):
    result = subprocess.run(command, cwd=cwd, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    with (OUTPUT / 'commands.log').open('a') as log:
        log.write('$ ' + ' '.join(map(str, command)) + '\n' + result.stdout)
    if result.returncode:
        raise RuntimeError(result.stdout)
    return result.stdout


def android():
    run(['./gradlew', 'test', 'jacocoTestCoverageVerification', '--no-daemon',
         '--console=plain'], cwd=HERE / 'android')
    report = HERE / 'android/build/reports/jacoco/test/jacocoTestReport.xml'
    tree = ET.parse(report)
    lines = tree.find("./counter[@type='LINE']")
    missed, covered = int(lines.attrib['missed']), int(lines.attrib['covered'])
    assert covered > 0 and missed == 0, f'Android uncovered: {missed}'
    return {'platform': 'Android Kotlin', 'covered': covered, 'lines': covered + missed}


def apple():
    if sys.platform != 'darwin':
        raise RuntimeError('Apple native coverage requires macOS and Xcode command line tools')
    build = OUTPUT / 'apple'
    build.mkdir(exist_ok=True)
    for module in ['Contacts', 'Flutter', 'UIKit']:
        run(['xcrun', 'swiftc', '-swift-version', '5', '-emit-module', '-emit-library',
             '-module-name', module, str(HERE / 'swift' / f'{module}.swift'),
             '-emit-module-path', str(build / f'{module}.swiftmodule'),
             '-o', str(build / f'lib{module}.dylib')])
    swift_sources = [PLUGIN / 'ios/Classes/ContactPermissionHandler.swift',
                     PLUGIN / 'ios/Classes/SwiftContactPermissionPlugin.swift']
    binary = build / 'swift_tests'
    run(['xcrun', 'swiftc', '-swift-version', '5', '-profile-generate',
         '-profile-coverage-mapping', '-I', str(build), '-L', str(build),
         '-lContacts', '-lFlutter', '-lUIKit', '-Xlinker', '-rpath', '-Xlinker', str(build),
         *map(str, swift_sources), str(HERE / 'swift/main.swift'), '-o', str(binary)])
    objc_source = PLUGIN / 'ios/Classes/ContactPermissionPlugin.m'
    objc_binary = build / 'objc_tests'
    run(['xcrun', 'clang', '-fprofile-instr-generate', '-fcoverage-mapping',
         '-fobjc-arc', '-framework', 'Foundation', '-I', str(HERE / 'objc'),
         '-I', str(PLUGIN / 'ios/Classes'), str(objc_source), str(HERE / 'objc/main.m'),
         '-o', str(objc_binary)])
    covered = total = 0
    for label, executable, sources in [('swift', binary, swift_sources),
                                       ('objc', objc_binary, [objc_source])]:
        profile = build / f'{label}.profraw'
        data = build / f'{label}.profdata'
        run([str(executable)], env={**os.environ, 'LLVM_PROFILE_FILE': str(profile)})
        run(['xcrun', 'llvm-profdata', 'merge', '-sparse', str(profile), '-o', str(data)])
        report = json.loads(run(['xcrun', 'llvm-cov', 'export', str(executable),
                                '-instr-profile=' + str(data), *map(str, sources)]))
        (build / f'{label}-coverage.json').write_text(json.dumps(report, indent=2))
        for file in report['data'][0]['files']:
            lines = file['summary']['lines']
            covered += lines['covered']
            total += lines['count']
            assert lines['covered'] == lines['count'], f"Uncovered native lines: {file['filename']}"
    assert total > 0
    return {'platform': 'Apple Swift/Objective-C', 'covered': covered, 'lines': total}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--platform', choices=['all', 'android', 'apple'], default='all')
    args = parser.parse_args()
    OUTPUT.mkdir(exist_ok=True)
    (OUTPUT / 'commands.log').write_text('')
    results = []
    if args.platform in ['all', 'android']:
        results.append(android())
    if args.platform in ['all', 'apple']:
        results.append(apple())
    (OUTPUT / 'summary.json').write_text(json.dumps(results, indent=2) + '\n')
    for result in results:
        print(f"{result['platform']}: {result['covered']}/{result['lines']} executable lines (100%)")


if __name__ == '__main__':
    main()

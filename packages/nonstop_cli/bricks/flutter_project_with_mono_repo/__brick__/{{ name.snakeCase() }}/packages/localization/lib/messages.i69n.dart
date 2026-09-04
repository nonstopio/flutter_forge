// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;

String get _languageCode => 'en';
String get _localeName => 'en';

String _plural(int count,
        {String? zero,
        String? one,
        String? two,
        String? few,
        String? many,
        String? other}) =>
    i69n.plural(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);
String _ordinal(int count,
        {String? zero,
        String? one,
        String? two,
        String? few,
        String? many,
        String? other}) =>
    i69n.ordinal(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);
String _cardinal(int count,
        {String? zero,
        String? one,
        String? two,
        String? few,
        String? many,
        String? other}) =>
    i69n.cardinal(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);

class Messages implements i69n.I69nMessageBundle {
  const Messages();
  AppMessages get app => AppMessages(this);
  GenericMessages get generic => GenericMessages(this);
  CommonMessages get common => CommonMessages(this);
  AuthMessages get auth => AuthMessages(this);
  ProfileMessages get profile => ProfileMessages(this);
  NavMessages get nav => NavMessages(this);
  NotificationsMessages get notifications => NotificationsMessages(this);
  ErrorsMessages get errors => ErrorsMessages(this);
  ValidationMessages get validation => ValidationMessages(this);
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'app':
        return app;
      case 'generic':
        return generic;
      case 'common':
        return common;
      case 'auth':
        return auth;
      case 'profile':
        return profile;
      case 'nav':
        return nav;
      case 'notifications':
        return notifications;
      case 'errors':
        return errors;
      case 'validation':
        return validation;
      default:
        return key;
    }
  }
}

class AppMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const AppMessages(this._parent);
  String get name => "{{name.titleCase()}}";
  String get description => "{{{description}}}";
  String get welcome_to_app => "Welcome to {{name.titleCase()}}!";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'name':
        return name;
      case 'description':
        return description;
      case 'welcome_to_app':
        return welcome_to_app;
      default:
        return key;
    }
  }
}

class GenericMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const GenericMessages(this._parent);
  String get ok => "OK";
  String get cancel => "Cancel";
  String get save => "Save";
  String get delete => "Delete";
  String get edit => "Edit";
  String get update => "Update";
  String get submit => "Submit";
  String get close => "Close";
  String get back => "Back";
  String get next => "Next";
  String get previous => "Previous";
  String get done => "Done";
  String get loading => "Loading...";
  String get error => "Error";
  String get success => "Success";
  String get warning => "Warning";
  String get info => "Info";
  String get retry => "Retry";
  String get refresh => "Refresh";
  String get yes => "Yes";
  String get no => "No";
  String get add => "+ Add";
  String get try_again => "Try Again";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'ok':
        return ok;
      case 'cancel':
        return cancel;
      case 'save':
        return save;
      case 'delete':
        return delete;
      case 'edit':
        return edit;
      case 'update':
        return update;
      case 'submit':
        return submit;
      case 'close':
        return close;
      case 'back':
        return back;
      case 'next':
        return next;
      case 'previous':
        return previous;
      case 'done':
        return done;
      case 'loading':
        return loading;
      case 'error':
        return error;
      case 'success':
        return success;
      case 'warning':
        return warning;
      case 'info':
        return info;
      case 'retry':
        return retry;
      case 'refresh':
        return refresh;
      case 'yes':
        return yes;
      case 'no':
        return no;
      case 'add':
        return add;
      case 'try_again':
        return try_again;
      default:
        return key;
    }
  }
}

class CommonMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const CommonMessages(this._parent);
  String get cancel => "Cancel";
  String get ok => "OK";
  String get save => "Save";
  String get delete => "Delete";
  String get edit => "Edit";
  String get try_again => "Try Again";
  String get week => "Week";
  String get month => "Month";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'cancel':
        return cancel;
      case 'ok':
        return ok;
      case 'save':
        return save;
      case 'delete':
        return delete;
      case 'edit':
        return edit;
      case 'try_again':
        return try_again;
      case 'week':
        return week;
      case 'month':
        return month;
      default:
        return key;
    }
  }
}

class AuthMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const AuthMessages(this._parent);
  String get register => "Register";
  String get sign_in => "Sign In";
  String get sign_out => "Sign Out";
  String get dont_have_account => "Don't have an account? ";
  String get already_have_account => "Already have an account? ";
  String get sign_out_confirmation => "Are you sure you want to sign out?";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'register':
        return register;
      case 'sign_in':
        return sign_in;
      case 'sign_out':
        return sign_out;
      case 'dont_have_account':
        return dont_have_account;
      case 'already_have_account':
        return already_have_account;
      case 'sign_out_confirmation':
        return sign_out_confirmation;
      default:
        return key;
    }
  }
}

class ProfileMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const ProfileMessages(this._parent);
  String get profile => "Profile";
  String get settings => "Settings";
  String get account => "Account";
  String get personal_info => "Personal Information";
  String get privacy_settings => "Privacy Settings";
  String get name => "Name";
  String get email_address => "Email Address";
  String get phone_number => "Phone Number";
  String get date_of_birth => "Date of Birth";
  String get delete_confirmation => "Delete Confirmation";
  String get delete_confirmation_message =>
      "Are you sure you want to delete this item? This action cannot be undone.";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'profile':
        return profile;
      case 'settings':
        return settings;
      case 'account':
        return account;
      case 'personal_info':
        return personal_info;
      case 'privacy_settings':
        return privacy_settings;
      case 'name':
        return name;
      case 'email_address':
        return email_address;
      case 'phone_number':
        return phone_number;
      case 'date_of_birth':
        return date_of_birth;
      case 'delete_confirmation':
        return delete_confirmation;
      case 'delete_confirmation_message':
        return delete_confirmation_message;
      default:
        return key;
    }
  }
}

class NavMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const NavMessages(this._parent);
  String get home => "Home";
  String get dashboard => "Dashboard";
  String get profile => "Profile";
  String get settings => "Settings";
  String get notifications => "Notifications";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'home':
        return home;
      case 'dashboard':
        return dashboard;
      case 'profile':
        return profile;
      case 'settings':
        return settings;
      case 'notifications':
        return notifications;
      default:
        return key;
    }
  }
}

class NotificationsMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const NotificationsMessages(this._parent);
  String get title => "Notifications";
  String get mark_as_read => "Mark as read";
  String get mark_all_read => "Mark all as read";
  String get delete => "Delete";
  String get filter_all => "All";
  String get filter_unread => "Unread";
  String get filter_read => "Read";
  String get type_reminder => "Reminder";
  String get type_alert => "Alert";
  String get type_promotion => "Promotion";
  String get type_system => "System";
  String get type_custom => "Custom";
  String get empty_title => "No notifications";
  String get empty_description =>
      "You're all caught up! New notifications will appear here.";
  String get delete_confirmation_title => "Delete notification?";
  String get delete_confirmation_message =>
      "This notification will be permanently removed from your list.";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'title':
        return title;
      case 'mark_as_read':
        return mark_as_read;
      case 'mark_all_read':
        return mark_all_read;
      case 'delete':
        return delete;
      case 'filter_all':
        return filter_all;
      case 'filter_unread':
        return filter_unread;
      case 'filter_read':
        return filter_read;
      case 'type_reminder':
        return type_reminder;
      case 'type_alert':
        return type_alert;
      case 'type_promotion':
        return type_promotion;
      case 'type_system':
        return type_system;
      case 'type_custom':
        return type_custom;
      case 'empty_title':
        return empty_title;
      case 'empty_description':
        return empty_description;
      case 'delete_confirmation_title':
        return delete_confirmation_title;
      case 'delete_confirmation_message':
        return delete_confirmation_message;
      default:
        return key;
    }
  }
}

class ErrorsMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const ErrorsMessages(this._parent);
  String get network_error => "Network error. Please check your connection.";
  String get unknown_error => "An unknown error occurred.";
  String get validation_error => "Please check your input and try again.";
  String get server_error => "Server error. Please try again later.";
  String get default_error_message =>
      "Oops! Something went wrong. Please try again.";
  String get user_not_found => "User not found. Please check your credentials.";
  String get default_error_description =>
      "We encountered an error while processing your request. We apologize for the inconvenience. Please try again later or contact support if the issue persists.";
  String get page_not_found => "Page Not Found";
  String get page_not_found_description =>
      "The page you are looking for does not exist.";
  String get unexpected_error => "An unexpected error occurred.";
  String get redirect_error => "Redirect Error";
  String get bad_request => "Invalid request. Please check your input.";
  String get unauthorized => "Authentication required. Please sign in again.";
  String get forbidden => "Access denied. You don't have permission.";
  String get not_found => "Requested resource not found.";
  String get conflict => "Data conflict. Please refresh and try again.";
  String get unprocessable_entity =>
      "Invalid data format. Please check your input.";
  String get internal_server_error => "Server error. Please try again later.";
  String get connection_timeout =>
      "Connection timeout. Please check your internet.";
  String get receive_timeout => "Request timeout. Please try again.";
  String get send_timeout => "Upload timeout. Please try again.";
  String get no_internet =>
      "No internet connection. Please check your network.";
  String get unknown_network => "Network error occurred. Please try again.";
  String format_exception_message(String code, String postfix) =>
      "This data is wearing the wrong costume, I don't recognize it [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "This data is not what I expected, I can't process it [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "Hmm, I can't seem to find that item in the list [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "Oops! That number is way out of my comfort zone [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "Hey! Something's not right with what you gave me [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "I'm a bit confused about what I should be doing right now [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "This feature is still under construction [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "Sorry, I don't know how to do that yet [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "Whoa! Too many things happening at once [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "My brain is full! Need to clear some space [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "I'm stuck in a loop and getting dizzy [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "Something unexpected happened, but don't worry [$code] $postfix";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'network_error':
        return network_error;
      case 'unknown_error':
        return unknown_error;
      case 'validation_error':
        return validation_error;
      case 'server_error':
        return server_error;
      case 'default_error_message':
        return default_error_message;
      case 'user_not_found':
        return user_not_found;
      case 'default_error_description':
        return default_error_description;
      case 'page_not_found':
        return page_not_found;
      case 'page_not_found_description':
        return page_not_found_description;
      case 'unexpected_error':
        return unexpected_error;
      case 'redirect_error':
        return redirect_error;
      case 'bad_request':
        return bad_request;
      case 'unauthorized':
        return unauthorized;
      case 'forbidden':
        return forbidden;
      case 'not_found':
        return not_found;
      case 'conflict':
        return conflict;
      case 'unprocessable_entity':
        return unprocessable_entity;
      case 'internal_server_error':
        return internal_server_error;
      case 'connection_timeout':
        return connection_timeout;
      case 'receive_timeout':
        return receive_timeout;
      case 'send_timeout':
        return send_timeout;
      case 'no_internet':
        return no_internet;
      case 'unknown_network':
        return unknown_network;
      case 'format_exception_message':
        return format_exception_message;
      case 'type_error_message':
        return type_error_message;
      case 'index_error_message':
        return index_error_message;
      case 'range_error_message':
        return range_error_message;
      case 'argument_error_message':
        return argument_error_message;
      case 'state_error_message':
        return state_error_message;
      case 'unimplemented_error_message':
        return unimplemented_error_message;
      case 'unsupported_error_message':
        return unsupported_error_message;
      case 'concurrent_modification_error_message':
        return concurrent_modification_error_message;
      case 'out_of_memory_error_message':
        return out_of_memory_error_message;
      case 'stack_overflow_error_message':
        return stack_overflow_error_message;
      case 'unknown_error_message':
        return unknown_error_message;
      default:
        return key;
    }
  }
}

class ValidationMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const ValidationMessages(this._parent);
  String get required_field => "This field is required";
  String get invalid_email => "Please enter a valid email address";
  String get password_too_short => "Password must be at least 8 characters";
  String get passwords_dont_match => "Passwords do not match";
  String invalid_key_config(String of, String key) =>
      "Invalid configuration for $key in $of. Please check your settings.";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'required_field':
        return required_field;
      case 'invalid_email':
        return invalid_email;
      case 'password_too_short':
        return password_too_short;
      case 'passwords_dont_match':
        return passwords_dont_match;
      case 'invalid_key_config':
        return invalid_key_config;
      default:
        return key;
    }
  }
}

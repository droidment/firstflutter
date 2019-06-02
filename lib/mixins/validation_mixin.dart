class ValidationMixin {
  String validateEmail(String value) {
    // This validator gets called by the formState(formKey) validate() function
    // return null if valid
    // otherwise string (with the error message) if in valid
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String validatePhone(String value) {
    RegExp exp =
        new RegExp(r"/^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/");
    if (exp.hasMatch(value)){
      return null; 
    }else{
      return "Please enter phone number";
    }
  }

  String validateInput(String value) {
    if (value.length < 4) {
      return 'Password must be more than 4 characters';
    }
    return null;
  }
}

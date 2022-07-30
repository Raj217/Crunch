class Validator {
  static bool isValidEmail(String email) {
    int len = email.length;
    int indexOfAt = email.indexOf('@');
    int indexOfPeriod = email.indexOf('.');
    int nAt = email.split('@').length - 1;
    int nPeriod = email.split('.').length - 1;
    if (nPeriod == 1 &&
            nAt == 1 &&
            indexOfAt <
                indexOfPeriod - 1 // . is after @ and . is not just next to @
            &&
            len - 1 >
                indexOfPeriod // ensuring that . is not the last and since . is after @ therefore @ cannot be last
        ) {
      return true;
    } else {
      return false;
    }
  }
}

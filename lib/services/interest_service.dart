// Service class containing pure Dart math functions to calculate Loan Interest
class InterestService {
  // 1. Calculate Simple Interest between two dates
  // Supports both "yearly" (365 days) and "monthly" (30 days) interest rates
  static double calculateSimpleInterest({
    required double principal,     // Original loan amount (P)
    required double rate,          // Interest rate percentage (R)
    required String rateType,      // Either "yearly" or "monthly"
    required String startDateText, // Start date saved as text (e.g., "2026-11-21")
    String? endDateText,           // Optional end date (if null, calculates till today)
  }) {
    // If principal or rate is 0 or negative, interest is 0
    if (principal <= 0 || rate <= 0) {
      return 0.0;
    }

    // Convert the start date text into a Dart DateTime object
    DateTime startDate = DateTime.tryParse(startDateText) ?? DateTime.now();

    // Determine the end date:
    // If endDateText is provided and not empty, use it; otherwise use today's date
    DateTime endDate;
    if (endDateText != null && endDateText.isNotEmpty) {
      endDate = DateTime.tryParse(endDateText) ?? DateTime.now();
    } else {
      endDate = DateTime.now();
    }

    // Calculate total number of days between startDate and endDate
    int totalDays = endDate.difference(startDate).inDays;

    // If endDate is before or same as startDate, no days have passed so interest is 0
    if (totalDays <= 0) {
      return 0.0;
    }

    double interest = 0.0;

    // Check whether the user selected a "monthly" rate or a "yearly" rate
    if (rateType == 'monthly') {
      // Monthly Formula: (Principal * MonthlyRate * Days) / (100 * 30)
      double timeInMonths = totalDays / 30.0;
      interest = (principal * rate * timeInMonths) / 100;
    } else {
      // Yearly Formula: (Principal * YearlyRate * Days) / (100 * 365)
      double timeInYears = totalDays / 365.0;
      interest = (principal * rate * timeInYears) / 100;
    }

    // Return the final calculated interest
    return interest;
  }

  // 2. Calculate Interest Till Today (Live accrued interest up to the current day)
  static double getInterestTillToday({
    required double principal,
    required double rate,
    required String rateType,
    required String startDateText,
  }) {
    return calculateSimpleInterest(
      principal: principal,
      rate: rate,
      rateType: rateType,
      startDateText: startDateText,
      endDateText: null, // Passing null tells the function to use DateTime.now()
    );
  }

  // 3. Calculate Total Interest Till Due Date (Full expected interest)
  static double getInterestTillDueDate({
    required double principal,
    required double rate,
    required String rateType,
    required String startDateText,
    required String dueDateText,
  }) {
    // If no due date was set, return interest till today instead
    if (dueDateText.isEmpty) {
      return getInterestTillToday(
        principal: principal,
        rate: rate,
        rateType: rateType,
        startDateText: startDateText,
      );
    }

    return calculateSimpleInterest(
      principal: principal,
      rate: rate,
      rateType: rateType,
      startDateText: startDateText,
      endDateText: dueDateText,
    );
  }

  // 4. Calculate Total Amount (Principal + Interest)
  static double calculateTotalAmount({
    required double principal,
    required double interest,
  }) {
    return principal + interest;
  }

  // 5. Calculate Remaining Balance left to pay (Total Amount - Already Paid)
  static double calculateRemainingBalance({
    required double totalAmount,
    required double paidAmount,
  }) {
    double remaining = totalAmount - paidAmount;
    // Ensure remaining balance never shows a negative number if overpaid
    return remaining < 0 ? 0.0 : remaining;
  }
}
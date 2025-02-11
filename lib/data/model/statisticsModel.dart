import 'package:edemand_partner/data/model/jobRequestModel.dart';

class StatisticsModel {
  List<CategoriesStatisticsModel>? caregories;
  MonthlyEarnings? monthlyEarnings;
  String? totalServices;
  String? totalOrders;
  String? totalBalance;
  String? totalCancles;
  String? totalRatings;
  String? numberOfRatings;
  String? currency;
  String? income;
  List<JobRequestModel>? openJobs;
  int? totalOpenJobs;

  StatisticsModel(
      {this.caregories,
      this.monthlyEarnings,
      this.totalServices,
      this.totalOrders,
      this.totalBalance,
      this.totalRatings,
      this.numberOfRatings,
      this.totalCancles,
      this.currency,
      this.income,
      this.openJobs,
      this.totalOpenJobs});

  StatisticsModel.fromJson(Map<String, dynamic> json) {
    if (json['caregories'] != null) {
      caregories = <CategoriesStatisticsModel>[];
      json['caregories'].forEach((v) {
        caregories!.add(CategoriesStatisticsModel.fromJson(v));
      });
    }

    if (json['open_jobs'] != null) {
      openJobs = <JobRequestModel>[];
      json['open_jobs'].forEach((v) {
        openJobs!.add(JobRequestModel.fromJson(v));
      });
    }

    monthlyEarnings = json['monthly_earnings'] != null
        ? MonthlyEarnings.fromJson(json['monthly_earnings'])
        : null;
    totalServices = json['total_services'];

    totalOrders = json['total_orders'];
    totalBalance = json['total_balance'];
    totalRatings = json['total_ratings'];
    numberOfRatings = json['number_of_ratings'];
    currency = json['currency'];
    income = json['income'];
    totalCancles = json['total_cancelled_orders'];
    totalOpenJobs = json['total_open_jobs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (caregories != null) {
      data['caregories'] =
          caregories!.map((CategoriesStatisticsModel v) => v.toJson()).toList();
    }
    if (openJobs != null) {
      data['open_jobs'] =
          openJobs!.map((JobRequestModel v) => v.toJson()).toList();
    }
    if (monthlyEarnings != null) {
      data['monthly_earnings'] = monthlyEarnings!.toJson();
    }
    data['total_services'] = totalServices;
    data['total_orders'] = totalOrders;
    data['total_balance'] = totalBalance;
    data['total_ratings'] = totalRatings;
    data['number_of_ratings'] = numberOfRatings;
    data['currency'] = currency;
    data['income'] = income;
    data['total_cancelled_orders'] = totalCancles;
    data['total_open_jobs'] = totalOpenJobs;
    return data;
  }

  @override
  String toString() {
    return 'StatisticsModel(caregories: $caregories, monthlyEarnings: $monthlyEarnings, totalServices: $totalServices, totalOrders: $totalOrders, totalBalance: $totalBalance, totalRatings: $totalRatings, numberOfRatings: $numberOfRatings, currency: $currency, income: $income, openJobs: $openJobs, )';
  }
}

class CategoriesStatisticsModel {
  String? name;
  String? totalServices;

  CategoriesStatisticsModel({this.name, this.totalServices});

  CategoriesStatisticsModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    totalServices = json['total_services'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['total_services'] = totalServices;
    return data;
  }
}

class MonthlyEarnings {
  List<MonthlySales>? monthlySales;

  MonthlyEarnings({this.monthlySales});

  MonthlyEarnings.fromJson(Map<String, dynamic> json) {
    if (json['monthly_sales'] != null) {
      monthlySales = <MonthlySales>[];
      json['monthly_sales'].forEach((v) {
        monthlySales!.add(MonthlySales.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (monthlySales != null) {
      data['monthly_sales'] =
          monthlySales!.map((MonthlySales v) => v.toJson()).toList();
    }
    return data;
  }
}

class MonthlySales {
  String? totalAmount;
  String? month;

  MonthlySales({this.totalAmount, this.month});

  MonthlySales.fromJson(Map<String, dynamic> json) {
    totalAmount = json['total_amount'];
    month = json['month'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_amount'] = totalAmount;
    data['month'] = month;
    return data;
  }
}

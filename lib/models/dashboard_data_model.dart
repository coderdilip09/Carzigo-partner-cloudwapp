import 'package:carzigo_partner/models/job_data_model.dart';
import 'package:carzigo_partner/models/json_parsers.dart';

class DashboardPartnerModel {
  DashboardPartnerModel({
    this.id,
    this.name,
    this.serviceArea,
    this.approval,
    this.kycStatus,
    this.status,
    this.availability,
  });

  final String? id;
  final String? name;
  final String? serviceArea;
  final String? approval;
  final String? kycStatus;
  final String? status;
  final String? availability;

  factory DashboardPartnerModel.fromJson(Map<String, dynamic> json) {
    return DashboardPartnerModel(
      id: asString(json['id']),
      name: asString(json['name']),
      serviceArea: asString(
        json['service_area'] ?? json['serviceArea'] ?? json['location'],
      ),
      approval: asString(json['approval']),
      kycStatus: asString(json['kyc_status'] ?? json['kycStatus']),
      status: asString(json['status']),
      availability: asString(json['availability']),
    );
  }
}

class DashboardTodayStatsModel {
  DashboardTodayStatsModel({this.completed = 0, this.inProgress = 0});

  final int completed;
  final int inProgress;

  factory DashboardTodayStatsModel.fromJson(Map<String, dynamic>? json) {
    return DashboardTodayStatsModel(
      completed: asInt(json?['completed']) ?? 0,
      inProgress: asInt(json?['in_progress'] ?? json?['inProgress']) ?? 0,
    );
  }
}

class DashboardMonthStatsModel {
  DashboardMonthStatsModel({this.completed = 0, this.avgRating});

  final int completed;
  final double? avgRating;

  factory DashboardMonthStatsModel.fromJson(Map<String, dynamic>? json) {
    return DashboardMonthStatsModel(
      completed: asInt(json?['completed']) ?? 0,
      avgRating: asDouble(json?['avg_rating'] ?? json?['avgRating']),
    );
  }
}

class DashboardDataModel {
  DashboardDataModel({
    this.partner,
    this.nextJob,
    this.todayStats,
    this.todaySchedule = const [],
    this.monthStats,
  });

  final DashboardPartnerModel? partner;
  final JobDataModel? nextJob;
  final DashboardTodayStatsModel? todayStats;
  final List<JobDataModel> todaySchedule;
  final DashboardMonthStatsModel? monthStats;

  String? get displayName => partner?.name;
  String? get serviceArea => partner?.serviceArea;
  int get todayCompleted => todayStats?.completed ?? 0;
  int get todayInProgress => todayStats?.inProgress ?? 0;
  int get monthCompleted => monthStats?.completed ?? 0;
  double? get monthAvgRating => monthStats?.avgRating;

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    final partnerMap = asMap(json['partner']);
    final nextJobMap = asMap(json['next_job'] ?? json['nextJob']);
    final todayStatsMap = asMap(json['today_stats'] ?? json['todayStats']);
    final monthStatsMap = asMap(json['month_stats'] ?? json['monthStats']);
    final rawSchedule =
        json['today_schedule'] ??
        json['todaySchedule'] ??
        json['today_jobs'] ??
        json['todayJobs'] ??
        json['schedule'];

    return DashboardDataModel(
      partner: partnerMap == null
          ? null
          : DashboardPartnerModel.fromJson(partnerMap),
      nextJob: nextJobMap == null ? null : JobDataModel.fromJson(nextJobMap),
      todayStats: DashboardTodayStatsModel.fromJson(todayStatsMap),
      todaySchedule: asModelList(rawSchedule, JobDataModel.fromJson),
      monthStats: DashboardMonthStatsModel.fromJson(monthStatsMap),
    );
  }
}

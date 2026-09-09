import 'package:carzigo_partner/models/json_parsers.dart';

class JobWorkflowStatus {
  JobWorkflowStatus._();

  static const String assigned = 'assigned';
  static const String onTheWay = 'on_the_way';
  static const String onSite = 'on_site';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

class JobListStatus {
  JobListStatus._();

  static const String upcoming = 'upcoming';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

class JobDataModel {
  JobDataModel({
    this.id,
    this.scheduleId,
    this.listStatus,
    this.workflowStatus,
    this.currentStep,
    this.serviceName,
    this.customerName,
    this.customerInitials,
    this.customerPhone,
    this.customerEmail,
    this.car,
    this.price,
    this.date,
    this.timeRange,
    this.address,
    this.notes,
    this.customerInstructions,
    this.assignedAt,
  });

  final String? id;
  final String? scheduleId;
  final String? listStatus;
  final String? workflowStatus;
  final int? currentStep;
  final String? serviceName;
  final String? customerName;
  final String? customerInitials;
  final String? customerPhone;
  final String? customerEmail;
  final String? car;
  final String? price;
  final String? date;
  final String? timeRange;
  final String? address;
  final String? notes;
  final String? customerInstructions;
  final String? assignedAt;

  int get step {
    if (currentStep != null) return currentStep!;
    switch (workflowStatus) {
      case JobWorkflowStatus.onTheWay:
        return 2;
      case JobWorkflowStatus.onSite:
        return 3;
      case JobWorkflowStatus.inProgress:
        return 4;
      case JobWorkflowStatus.completed:
        return 5;
      case JobWorkflowStatus.assigned:
      default:
        return 1;
    }
  }

  factory JobDataModel.fromJson(Map<String, dynamic> json) {
    final customer = asMap(json['customer']);
    return JobDataModel(
      id: asString(
        json['id'] ?? json['_id'] ?? json['jobId'] ?? json['job_id'],
      ),
      scheduleId: asString(
        json['scheduleId'] ?? json['schedule_id'] ?? json['bookingId'],
      ),
      listStatus: asString(
        json['listStatus'] ?? json['list_status'] ?? json['tab'],
      ),
      workflowStatus: asString(
        json['workflowStatus'] ??
            json['workflow_status'] ??
            json['jobStatus'] ??
            json['status'],
      ),
      currentStep: asInt(
        json['currentStep'] ?? json['current_step'] ?? json['step'],
      ),
      serviceName: asString(
        json['serviceName'] ?? json['service_name'] ?? json['service'],
      ),
      customerName: asString(
        json['customerName'] ?? json['customer_name'] ?? customer?['name'],
      ),
      customerInitials: asString(
        json['customerInitials'] ??
            json['customer_initials'] ??
            customer?['initials'],
      ),
      customerPhone: asString(
        json['customerPhone'] ?? json['customer_phone'] ?? customer?['phone'],
      ),
      customerEmail: asString(
        json['customerEmail'] ?? json['customer_email'] ?? customer?['email'],
      ),
      car: asString(json['car'] ?? json['vehicle'] ?? json['carName']),
      price: asString(json['price'] ?? json['amount']),
      date: asString(
        json['date'] ?? json['serviceDate'] ?? json['service_date'],
      ),
      timeRange: asString(
        json['timeRange'] ?? json['time_range'] ?? json['time'],
      ),
      address: asString(json['address'] ?? json['serviceAddress']),
      notes: asString(
        json['notes'] ?? json['serviceNotes'] ?? json['service_notes'],
      ),
      customerInstructions: asString(
        json['customerInstructions'] ?? json['customer_instructions'],
      ),
      assignedAt: asString(json['assignedAt'] ?? json['assigned_at']),
    );
  }
}

class ScheduleListDataModel {
  ScheduleListDataModel({
    this.totalJobs,
    this.completedCount,
    this.inProgressCount,
    this.upcomingCount,
    this.cancelledCount,
    this.tab,
    this.jobs = const [],
  });

  final int? totalJobs;
  final int? completedCount;
  final int? inProgressCount;
  final int? upcomingCount;
  final int? cancelledCount;
  final String? tab;
  final List<JobDataModel> jobs;

  String get totalJobsLabel => _pad(totalJobs);
  String get completedLabel => _pad(completedCount);
  String get inProgressLabel => _pad(inProgressCount);

  static String _pad(int? value) => (value ?? 0).toString().padLeft(2, '0');

  factory ScheduleListDataModel.fromJson(dynamic json) {
    final map = asMap(json);
    if (map == null) {
      return ScheduleListDataModel(
        jobs: asModelList(json, JobDataModel.fromJson),
      );
    }

    final stats = asMap(map['stats']);
    final rawJobs = map['items'] ?? map['jobs'] ?? map['list'] ?? map['data'];
    return ScheduleListDataModel(
      totalJobs: asInt(
        stats?['total_jobs'] ??
            stats?['totalJobs'] ??
            map['totalJobs'] ??
            map['total_jobs'] ??
            map['total'],
      ),
      completedCount: asInt(
        stats?['completed'] ??
            map['completedCount'] ??
            map['completed_count'] ??
            map['completed'],
      ),
      inProgressCount: asInt(
        stats?['in_progress'] ??
            stats?['inProgress'] ??
            map['inProgressCount'] ??
            map['in_progress_count'],
      ),
      upcomingCount: asInt(map['upcomingCount'] ?? map['upcoming_count']),
      cancelledCount: asInt(map['cancelledCount'] ?? map['cancelled_count']),
      tab: asString(map['tab']),
      jobs: asModelList(rawJobs, JobDataModel.fromJson),
    );
  }
}

import 'package:carzigo_partner/models/json_parsers.dart';

class JobWorkflowStatus {
  JobWorkflowStatus._();

  static const String assigned = 'assigned';
  static const String onTheWay = 'on_the_way';
  /// Backend status value for on-site.
  static const String arrived = 'arrived';
  static const String onSite = 'on_site';
  /// Backend status value for in-progress wash.
  static const String serviceStarted = 'service_started';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  /// Map UI step statuses to API values the backend accepts.
  static String toApiStatus(String status) {
    switch (status) {
      case onSite:
        return arrived;
      case inProgress:
        return serviceStarted;
      default:
        return status;
    }
  }
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
    this.uiStatus,
    this.displayTag,
    this.canUpdate,
    this.currentStep,
    this.serviceName,
    this.customerName,
    this.customerInitials,
    this.customerPhone,
    this.customerEmail,
    this.car,
    this.vehicleModel,
    this.plateNumber,
    this.price,
    this.date,
    this.timeRange,
    this.slotMinutes,
    this.address,
    this.lat,
    this.lng,
    this.notes,
    this.customerInstructions,
    this.assignedAt,
  });

  final String? id;
  final String? scheduleId;
  final String? listStatus;
  final String? workflowStatus;
  final String? uiStatus;
  final String? displayTag;
  final bool? canUpdate;
  final int? currentStep;
  final String? serviceName;
  final String? customerName;
  final String? customerInitials;
  final String? customerPhone;
  final String? customerEmail;
  final String? car;
  final String? vehicleModel;
  final String? plateNumber;
  final String? price;
  final String? date;
  final String? timeRange;
  final int? slotMinutes;
  final String? address;
  final double? lat;
  final double? lng;
  final String? notes;
  final String? customerInstructions;
  final String? assignedAt;

  int get step {
    if (currentStep != null) return currentStep!;
    switch (workflowStatus) {
      case JobWorkflowStatus.onTheWay:
        return 2;
      case JobWorkflowStatus.onSite:
      case JobWorkflowStatus.arrived:
        return 3;
      case JobWorkflowStatus.inProgress:
      case JobWorkflowStatus.serviceStarted:
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
    final addressMap = asMap(json['address']);
    final vehicleModel = asString(
      json['vehicle_model'] ?? json['vehicleModel'] ?? json['carName'],
    );
    final plateNumber = asString(
      json['plate_number'] ?? json['plateNumber'] ?? json['registration'],
    );
    final carLabel = asString(
          json['car'] ?? json['vehicle_label'] ?? json['vehicle'],
        ) ??
        [
          if (vehicleModel != null && vehicleModel.isNotEmpty) vehicleModel,
          if (plateNumber != null && plateNumber.isNotEmpty) plateNumber,
        ].join(' • ');

    return JobDataModel(
      id: asString(
        json['id'] ?? json['_id'] ?? json['jobId'] ?? json['job_id'],
      ),
      scheduleId: asString(
        json['scheduleId'] ??
            json['schedule_id'] ??
            json['schedule_code'] ??
            json['bookingId'],
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
      uiStatus: asString(json['ui_status'] ?? json['uiStatus']),
      displayTag: asString(json['display_tag'] ?? json['displayTag']),
      canUpdate: asBool(json['can_update'] ?? json['canUpdate']),
      currentStep: asInt(
        json['currentStep'] ?? json['current_step'] ?? json['step'],
      ),
      serviceName: asString(
        json['serviceName'] ??
            json['service_name'] ??
            json['service_type'] ??
            json['service'],
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
        json['customerPhone'] ??
            json['customer_phone'] ??
            json['customer_mobile'] ??
            customer?['phone'] ??
            customer?['mobile'],
      ),
      customerEmail: asString(
        json['customerEmail'] ??
            json['customer_email'] ??
            customer?['email'],
      ),
      car: carLabel.isNotEmpty ? carLabel : null,
      vehicleModel: vehicleModel,
      plateNumber: plateNumber,
      price: asString(json['price'] ?? json['amount'] ?? json['earnings']),
      date: _formatDisplayDate(
        asString(json['date'] ?? json['serviceDate'] ?? json['service_date']),
      ),
      timeRange: _formatDisplayTimeRange(
        asString(
          json['time_range'] ??
              json['timeRange'] ??
              json['time'] ??
              json['scheduled_time'],
        ),
        asInt(json['slot_minutes'] ?? json['slotMinutes']),
      ),
      slotMinutes: asInt(json['slot_minutes'] ?? json['slotMinutes']) ?? 60,
      address: asString(
        addressMap?['line'] ??
            json['service_address'] ??
            json['address'] ??
            json['serviceAddress'] ??
            json['community'],
      ),
      lat: asDouble(
        addressMap?['lat'] ?? json['lat'] ?? json['gps_lat'],
      ),
      lng: asDouble(
        addressMap?['lng'] ?? json['lng'] ?? json['gps_lng'],
      ),
      notes: asString(
        json['notes'] ?? json['serviceNotes'] ?? json['service_notes'],
      ),
      customerInstructions: asString(
        json['customerInstructions'] ?? json['customer_instructions'],
      ),
      assignedAt: asString(json['assignedAt'] ?? json['assigned_at']),
    );
  }

  static String? _formatDisplayDate(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    final iso = DateTime.tryParse(value);
    if (iso != null) {
      final d = DateTime(iso.year, iso.month, iso.day);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
    }
    return value;
  }

  static String? _formatDisplayTimeRange(String? raw, int? slotMinutes) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;

    final hasAmPm = RegExp(r'\b(am|pm)\b', caseSensitive: false).hasMatch(value);
    final hasRangeSep = value.contains('-') ||
        value.contains('–') ||
        value.contains('—') ||
        RegExp(r'\bto\b', caseSensitive: false).hasMatch(value);
    if (hasAmPm && hasRangeSep) return value;

    final single = _parseClock(value);
    if (single != null) {
      final duration = (slotMinutes != null && slotMinutes > 0)
          ? slotMinutes
          : 60;
      final endTotal = single.$1 * 60 + single.$2 + duration;
      return '${_toAmPm(single.$1, single.$2)} - ${_toAmPm((endTotal ~/ 60) % 24, endTotal % 60)}';
    }

    // Range in 24h e.g. "09:00 - 10:00"
    final parts = value.split(RegExp(r'\s*(?:-|–|—|to)\s*', caseSensitive: false));
    if (parts.length >= 2) {
      final start = _parseClock(parts[0]);
      final end = _parseClock(parts[1]);
      if (start != null && end != null) {
        return '${_toAmPm(start.$1, start.$2)} - ${_toAmPm(end.$1, end.$2)}';
      }
    }

    if (hasAmPm) return value;
    return value;
  }

  static (int, int)? _parseClock(String raw) {
    final m = RegExp(
      r'^(\d{1,2}):(\d{2})(?:\s*([AaPp][Mm]))?$',
    ).firstMatch(raw.trim());
    if (m == null) return null;
    var h = int.tryParse(m.group(1)!) ?? 0;
    final min = int.tryParse(m.group(2)!) ?? 0;
    final period = m.group(3)?.toUpperCase();
    if (period == 'PM' && h < 12) h += 12;
    if (period == 'AM' && h == 12) h = 0;
    return (h, min);
  }

  static String _toAmPm(int hour24, int minute) {
    final ampm = hour24 >= 12 ? 'PM' : 'AM';
    var h = hour24 % 12;
    if (h == 0) h = 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
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

import 'package:edemand_partner/data/model/dataOutput.dart';
import 'package:edemand_partner/data/model/jobRequestModel.dart';
import 'package:edemand_partner/utils/api.dart';
import 'package:edemand_partner/utils/uiUtils.dart';

class jobRequestRepository {
  //
  Future<DataOutput<JobRequestModel>> fetchCustomJobRequest(
      {required int offset, required String? jobType}) async {
    try {
      final Map<String, dynamic> parameters = {
        "job_type": jobType,
        Api.offset: offset,
        Api.limit: UiUtils.limit
      };
      final Map<String, dynamic> response = await Api.post(
        url: Api.getCustomRequestJob,
        parameter: parameters,
        useAuthToken: true,
      );

      List<JobRequestModel> modelList;
      if (response['data'].isEmpty) {
        modelList = [];
      } else {
        modelList = (response['data'] as List).map((element) {
          return JobRequestModel.fromJson(element);
        }).toList();
      }

      return DataOutput<JobRequestModel>(
        total: response['total'] ?? "0",
        modelList: modelList,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> fetchCustomJobValue(
      {String? customJobValue}) async {
    try {
      final Map<String, dynamic> response = await Api.post(
        url: Api.manageCustomJobRequest,
        parameter: {Api.customJobValue: customJobValue},
        useAuthToken: true,
      );

      return {
        'message': response['message'],
        'error': response['error'],
      };
    } catch (e) {
      //
      return {
        'message': e.toString(),
        'error': true,
      };
    }
  }

  Future<Map<String, dynamic>> applyForCustomJob(
      {required String? id,
      required String? counterPrice,
      required String? coverNote,
      required String? duration,
      String? taxId}) async {
    try {
      final Map<String, dynamic> parameters = {
        "custom_job_request_id": id,
        "counter_price": counterPrice,
        "cover_note": coverNote,
        "duration": duration,
        "tax_id": taxId
      };
      final response = await Api.post(
        url: Api.applyForCustomJob,
        parameter: parameters,
        useAuthToken: true,
      );

      return {
        'error': response['error'],
        'message': response['message'],
        'data': response['data'] ?? []
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}

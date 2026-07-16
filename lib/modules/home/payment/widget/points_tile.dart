import 'package:darbak/language/locale.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/api_path.dart';
import '../../../../core/constants/langCode.dart';
import '../../../../core/helpers/SharedPreference/pereferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../profile/blocs/profile_cubit/profile_cubit.dart';

class PointsTile extends StatefulWidget {
  final String orderId;

  const PointsTile({Key? key, required this.orderId}) : super(key: key);

  @override
  _PointsTileState createState() => _PointsTileState();
}

class _PointsTileState extends State<PointsTile> {
  final TextEditingController _controller = TextEditingController();
  final Dio _dio = Dio();
  String? _pointsMessage;
  bool _showClearButton = false;
  bool _showApplyButton = true;
  int? _availablePoints;
  String? _points;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fetch points data
  Future<void> _fetchPointsData(String idNumber) async {
    if (idNumber.isEmpty) return;

    try {
      final response = await _dio.get(
        '$oracleApi/customerSync/$idNumber',
        options: _buildHeaders(),
      );

      final fetchedPoints = response.data['points'];
      setState(() {
        _points = fetchedPoints?.toString() ?? '0';
        _availablePoints = int.tryParse(_points!);
      });
    } catch (e) {
      print(e is DioException ? e.response?.data : "Unexpected Error: $e");
    }
  }

  // points input to used.
  Future<void> _applyPoints() async {
    final pointsText = _controller.text.trim();
    final locale = AppLocalizations.of(context);


    if (pointsText.isEmpty || int.tryParse(pointsText) == null) {
      setState(() => _pointsMessage = locale!.pleaseEnterYourPoints);
      _hideMessageAfterDelay();

      return;
    }

    try {
      final token = await SharedPreferencesHelper().getToken();
      final response = await _dio.post(
        pointsPath,
        options: _buildHeaders(token: token),
        data: FormData.fromMap({
          'order_id': widget.orderId,
          'user_points': _availablePoints,
          'used_points': pointsText,
        }),
      );

      setState(() {
        if (response.data['error'] == null) {
          _pointsMessage = locale!.discountPointsApplied;
          _showClearButton = true;
          _showApplyButton = false;
        } else {
          _pointsMessage = response.data['error'];
        }
      });
      _hideMessageAfterDelay();
    } catch (_) {
      _showClearButton = true;
      _showApplyButton = false;
      setState(() => _pointsMessage = locale!.dontHaveAnyPoints);
      _hideMessageAfterDelay();
    }
  }

  Future<void> _deletePointValue() async {
    final locale = AppLocalizations.of(context);

    try {
      final token = await SharedPreferencesHelper().getToken();
      final response = await _dio.post(
        pointsDeletePath,
        options: _buildHeaders(token: token),
        data: FormData.fromMap({
          'order_id': widget.orderId,
        }),
      );

      setState(() {
        if (response.data['error'] == null) {
          _pointsMessage = locale!.discountPointsDeleted;
          _showClearButton = false;
          _showApplyButton = true;
          _hideMessageAfterDelay();
        } else {
          _pointsMessage = response.data['error'];
          _hideMessageAfterDelay();
        }
      });
    } catch (_) {
      _showClearButton = false;
      _showApplyButton = true;
      setState(() => _pointsMessage = locale!.dontHaveAnyPoints);
      _hideMessageAfterDelay();
    }
  }

  Options _buildHeaders({String? token}) {
    return Options(
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept-Language": langCode.isEmpty ? 'en' : langCode,
        "Content-Type": "application/json",
      },
    );
  }

  void _hideMessageAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _pointsMessage = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Skeletonizer(
                enabled: true,
                child: _buildInputRow(context, locale),
              );
            }

            if (state is ProfileSuccess || state is ProfileFailed) {
              final idNumber = (state is ProfileSuccess &&
                  state.profileModel.customerData != null)
                  ? state.profileModel.customerData!.idNumber ?? ''
                  : "0";

              if (idNumber.isNotEmpty && _availablePoints == null) {
                _fetchPointsData(idNumber);
              }

              return _buildInputRow(context, locale);
            }

            return const SizedBox.shrink();
          },
        ),
        if (_availablePoints != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${locale!.pointsBalance}$_availablePoints = ${_availablePoints! ~/ 10} ${locale.sar}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (_pointsMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _pointsMessage!,
              style: TextStyle(
                color: Color(0xff327B5B),
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'ThmanyahSans',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputRow(BuildContext context, AppLocalizations? locale) {
    return Container(
      height: 36.h,
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding:   EdgeInsets.all(8.sp),
      decoration: BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 0.6,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style:  TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14.0,
                fontFamily: 'ThmanyahSans',
                fontWeight: FontWeight.w500,
              ),
              onChanged: (value) {
                setState(() {
                //  _showClearButton = value.isNotEmpty;
                //   _showApplyButton = value.isEmpty;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                hintText: locale!.addYourPointsHint,
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                suffixIcon: _showClearButton
                    ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.clear();
                      _showClearButton = false;
                      _showApplyButton = true;
                     // _pointsMessage = null;
                    });

                    _deletePointValue();
                  },
                  child:  Icon(Icons.clear, color: Theme.of(context).colorScheme.onPrimary, size: 20,),
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          if (_showApplyButton)
            Bounce(
              onTap: _controller.text.isNotEmpty ? _applyPoints : null,
              child: Text(
                locale.apply!.toUpperCase(),
                style: TextStyle(
                  color: _controller.text.isNotEmpty ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                  fontSize: 12.sp,
                  fontFamily: 'ThmanyahSans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

}

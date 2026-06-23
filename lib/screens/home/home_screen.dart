import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:composable_ui_kit/composable_ui_kit.dart';

import '../../injection_container.dart';
import '../global/presentation/blocs/global/global_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white,
        ),
        child: _buildBody(context),
      ),
    );
  }

  BlocProvider<GlobalBloc> _buildBody(BuildContext context) {
    return BlocProvider<GlobalBloc>(
      create: (_) => sl<GlobalBloc>(),
      child: ResponsiveContainer(
        child: ResponsivePadding(
          padding: EdgeInsets.all(context.sp(16)),
          child: Column(
            children: <Widget>[
              context.gapV(48), // Responsive vertical gap
              _buildHeader(context),
              context.gapV(32),
              _buildContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ResponsiveLayout(
      compact: (context) => _buildCompactHeader(context),
      medium: (context) => _buildMediumHeader(context),
      expanded: (context) => _buildExpandedHeader(context),
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          "Draft Home (Phone)",
          style: context.appTypography.headlineLarge.copyWith(
            color: context.appColors.onBackground,
            fontSize: context.fontSize(28),
          ),
          textAlign: TextAlign.center,
        ),
        context.gapV(8),
        Text(
          "Compact Layout",
          style: context.appTypography.bodyMedium.copyWith(
            color: context.appColors.onSurface,
            fontSize: context.fontSize(14),
          ),
        ),
      ],
    );
  }

  Widget _buildMediumHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          "Draft Home (Tablet)",
          style: context.appTypography.headlineLarge.copyWith(
            color: context.appColors.onBackground,
            fontSize: context.fontSize(32),
          ),
          textAlign: TextAlign.center,
        ),
        context.gapV(12),
        Text(
          "Medium Layout - More breathing room",
          style: context.appTypography.bodyLarge.copyWith(
            color: context.appColors.onSurface,
            fontSize: context.fontSize(16),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Draft Home (Desktop)",
                style: context.appTypography.displayMedium.copyWith(
                  color: context.appColors.onBackground,
                  fontSize: context.fontSize(36),
                ),
                textAlign: TextAlign.center,
              ),
              context.gapV(16),
              Text(
                "Expanded Layout - Optimized for large screens",
                style: context.appTypography.bodyLarge.copyWith(
                  color: context.appColors.onSurface,
                  fontSize: context.fontSize(18),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // Responsive Box with width/height
        ResponsiveBox(
          width: 250,
          height: 120,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.appColors.primaryContainer,
            borderRadius: context.appRadius.lgRadius,
          ),
          child: Center(
            child: Text(
              'Responsive Container\n${context.deviceSize.name}\n${context.width(250).round()}×${context.height(120).round()}px',
              style: context.appTypography.bodyMedium.copyWith(
                color: context.appColors.onPrimaryContainer,
                fontSize: context.fontSize(14),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        context.gapV(16),
        
        // Square responsive widget
        Container(
          width: context.r(80),
          height: context.r(80),
          decoration: BoxDecoration(
            color: context.appColors.secondaryContainer,
            borderRadius: context.appRadius.mdRadius,
          ),
          child: Center(
            child: Text(
              '${context.r(80).round()}px\nSquare',
              style: context.appTypography.bodySmall.copyWith(
                color: context.appColors.onSecondaryContainer,
                fontSize: context.fontSize(12),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        context.gapV(16),
        
        // Max width constraint example
        Container(
          constraints: context.constraints(maxWidth: 300),
          padding: context.paddingAll(12),
          decoration: BoxDecoration(
            color: context.appColors.tertiaryContainer,
            borderRadius: context.appRadius.smRadius,
          ),
          child: Text(
            'Max width: ${context.maxWidth(300).round()}px\nThis container has responsive max width constraint',
            style: context.appTypography.bodySmall.copyWith(
              color: context.appColors.onTertiaryContainer,
              fontSize: context.fontSize(12),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        context.gapV(24),
        ResponsiveVisibility(
          visibleOn: {DeviceSize.medium, DeviceSize.expanded},
          child: Container(
            padding: context.paddingAll(16),
            decoration: BoxDecoration(
              color: context.appColors.secondaryContainer,
              borderRadius: context.appRadius.mdRadius,
            ),
            child: Text(
              'This content only appears on tablets and desktop',
              style: context.appTypography.bodyMedium.copyWith(
                color: context.appColors.onSecondaryContainer,
                fontSize: context.fontSize(14),
              ),
            ),
          ),
        ),
        ResponsiveVisibility(
          visibleOn: {DeviceSize.compact},
          child: Container(
            padding: context.paddingAll(12),
            decoration: BoxDecoration(
              color: context.appColors.tertiaryContainer,
              borderRadius: context.appRadius.smRadius,
            ),
            child: Text(
              'This content only appears on phones',
              style: context.appTypography.bodySmall.copyWith(
                color: context.appColors.onTertiaryContainer,
                fontSize: context.fontSize(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/models/deal_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../core/services/analytics_service.dart';
import '../auth/login_screen.dart';
import 'app_snackbar.dart';

class DealCard extends StatefulWidget {
  final DealModel deal;
  final VoidCallback? onTap;

  // ⭐ New fields
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool showCategory;

  const DealCard({
    super.key,
    required this.deal,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showCategory = false,
  });

  @override
  State<DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<DealCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.durationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    debugPrint('🖱️ DealCard tapped: ${widget.deal.id}');
    try {
      context.read<AnalyticsService>().trackDealCardClick(widget.deal.id);
    } catch (e) {
      debugPrint('⚠️ Analytics Error in DealCard: $e');
    }

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(widget.deal.expiresAt);
    final AuthService authService = AuthService();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
        _handleTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: AppTheme.kLightBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.kCardBorder),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------- IMAGE SECTION --------------------
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: isLandscape
                        ? 2.2
                        : (1280 / 700),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusMd),
                      ),
                      child: widget.deal.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.deal.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.kDarkBackground.withValues(alpha: 0.5),
                                child: Center(
                                  child: SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.kElectricLime,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.kDarkBackground,
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: AppTheme.kSubtleText,
                                  size: AppTheme.iconLg,
                                ),
                              ),
                            )
                          : Container(
                              color: AppTheme.kDarkBackground,
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: AppTheme.kSubtleText,
                                size: AppTheme.iconLg,
                              ),
                            ),
                    ),
                  ),
                  // -------------------- DISCOUNT BADGE --------------------
                  if (widget.deal.discountValue.isNotEmpty)
                    PositionedDirectional(
                      top: AppTheme.spacing8,
                      start: AppTheme.spacing8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.redAccent,
                              Colors.red.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.deal.discountValue,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isLandscape ? 7.sp : 9.sp,
                          ),
                        ),
                      ),
                    ),
                  // -------------------- FAVORITE BUTTON --------------------
                  PositionedDirectional(
                    top: AppTheme.spacing8,
                    end: AppTheme.spacing8,
                    child: _FavoriteButton(
                      isFavorite: widget.isFavorite,
                      size: isLandscape ? 12.w : 15.w,
                      onTap: () {
                        if (authService.currentUser == null) {
                          AppSnackbar.loginRequired(
                            context,
                            onLogin: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }
                        if (widget.onFavoriteToggle != null) {
                          widget.onFavoriteToggle!();
                        }
                      },
                    ),
                  ),
                ],
              ),
              // -------------------- INFO SECTION --------------------
              Expanded(
                child: ClipRect(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                      vertical: AppTheme.spacing4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Company Name & Partner Badge
                        if (widget.deal.companyName != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.deal.companyName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppTheme.kSubtleText,
                                    fontSize: isLandscape ? 9.sp : 10.sp,
                                  ),
                                ),
                              ),
                              if (widget.deal.companyIsPartner) ...[
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.verified,
                                  color: AppTheme.kElectricLime,
                                  size: isLandscape ? 10.sp : 12.sp,
                                ),
                              ],
                            ],
                          ),

                        // Title
                        Text(
                          widget.deal.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.kLightText,
                            fontWeight: FontWeight.bold,
                            fontSize: isLandscape ? 10.sp : 11.sp,
                            height: 1.2,
                          ),
                        ),

                        const Spacer(),

                        // 1. Category
                        Text(
                          (widget.deal.categoryName != null && widget.deal.categoryName!.isNotEmpty)
                              ? widget.deal.categoryName!
                              : 'عرض',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.kElectricLime,
                            fontSize: isLandscape ? 9.sp : 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        
                        // 2. Expiry Date
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: isLandscape ? 10.w : 11.w,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: AppTheme.spacing4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: isLandscape ? 9.sp : 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated favorite button with scale and color transition
class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final double size;
  final VoidCallback onTap;

  const _FavoriteButton({
    required this.isFavorite,
    required this.size,
    required this.onTap,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.durationFast,
      lowerBound: 0.8,
      upperBound: 1.2,
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(_FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite && widget.isFavorite) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: ScaleTransition(
          scale: _controller,
          child: AnimatedSwitcher(
            duration: AppTheme.durationFast,
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(widget.isFavorite),
              color: widget.isFavorite ? Colors.redAccent : Colors.white,
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}

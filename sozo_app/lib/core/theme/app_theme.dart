import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ポップで楽しい活気ある色彩パレット
  static const Color primaryColor = Color(0xFF6366F1); // 鮮やかなインディゴ
  static const Color secondaryColor = Color(0xFF8B5CF6); // 鮮やかなパープル
  static const Color accentColor = Color(0xFFF59E0B); // エネルギッシュなオレンジ
  static const Color backgroundColor = Color(0xFFFEFBFF); // 温かみのあるホワイト
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFF8F9FF); // ソフトラベンダー
  static const Color errorColor = Color(0xFFF43F5E); // 鮮やかなレッド
  static const Color successColor = Color(0xFF10B981); // フレッシュグリーン
  static const Color warningColor = Color(0xFFF59E0B); // ビビッドオレンジ
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color dividerColor = Color(0xFFE2E8F0);
  
  // 新しいポップなアクセントカラー
  static const Color popPink = Color(0xFFEC4899);
  static const Color popMint = Color(0xFF06D6A0);
  static const Color popYellow = Color(0xFFFACC15);
  static const Color popBlue = Color(0xFF3B82F6);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    scaffoldBackgroundColor: backgroundColor,
    // 洗練されたアニメーション設定
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      titleTextStyle: GoogleFonts.mPlusRounded1c(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: primaryColor.withOpacity(0.15),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: dividerColor, width: 1),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.3),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.white.withOpacity(0.2);
          }
          return null;
        }),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(color: primaryColor.withOpacity(0.5), width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        foregroundColor: textPrimary,
        textStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textSecondary,
        textStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      hintStyle: GoogleFonts.mPlusRounded1c(
        color: textTertiary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    // 洗練されたテキストテーマ
    textTheme: TextTheme(
      displayLarge: GoogleFonts.mPlusRounded1c(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -1.5,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.mPlusRounded1c(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -1.0,
        height: 1.3,
      ),
      displaySmall: GoogleFonts.mPlusRounded1c(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.8,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.mPlusRounded1c(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.mPlusRounded1c(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.3,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.mPlusRounded1c(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: -0.2,
        height: 1.5,
      ),
      bodyLarge: GoogleFonts.mPlusRounded1c(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: -0.2,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.mPlusRounded1c(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: -0.1,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.mPlusRounded1c(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cardColor,
      side: BorderSide(color: dividerColor),
      labelStyle: GoogleFonts.mPlusRounded1c(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  // ダークテーマ用のカラー
  static const Color darkPrimaryColor = Color(0xFFECF0F1); // ライトグレー
  static const Color darkSecondaryColor = Color(0xFFBDC3C7); // ソフトグレー
  static const Color darkBackgroundColor = Color(0xFF1A1D1E); // ダークチャコール
  static const Color darkSurfaceColor = Color(0xFF222628); // ミディアムダーク
  static const Color darkCardColor = Color(0xFF2C3134); // カードグレー
  static const Color darkDividerColor = Color(0xFF3A3F42);
  static const Color darkTextPrimary = Color(0xFFECF0F1);
  static const Color darkTextSecondary = Color(0xFFBDC3C7);
  static const Color darkTextTertiary = Color(0xFF7F8C8D);
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkSecondaryColor,
      tertiary: accentColor,
      surface: darkSurfaceColor,
      background: darkBackgroundColor,
      error: errorColor,
      onPrimary: darkBackgroundColor,
      onSecondary: darkBackgroundColor,
      onSurface: darkTextPrimary,
      onBackground: darkTextPrimary,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    // 洗練されたアニメーション設定
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: darkTextPrimary,
      titleTextStyle: GoogleFonts.mPlusRounded1c(
        color: darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: darkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: darkDividerColor, width: 1),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        backgroundColor: darkPrimaryColor,
        foregroundColor: darkBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(color: darkDividerColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        foregroundColor: darkTextPrimary,
        textStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkTextSecondary,
        textStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkDividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkDividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      filled: true,
      fillColor: darkCardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      hintStyle: GoogleFonts.mPlusRounded1c(
        color: darkTextTertiary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    // 洗練されたテキストテーマ
    textTheme: TextTheme(
      displayLarge: GoogleFonts.mPlusRounded1c(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: darkTextPrimary,
        letterSpacing: -1.5,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.mPlusRounded1c(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
        letterSpacing: -1.0,
        height: 1.3,
      ),
      displaySmall: GoogleFonts.mPlusRounded1c(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
        letterSpacing: -0.8,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.mPlusRounded1c(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
        letterSpacing: -0.5,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.mPlusRounded1c(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
        letterSpacing: -0.3,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.mPlusRounded1c(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: darkTextPrimary,
        letterSpacing: -0.2,
        height: 1.5,
      ),
      bodyLarge: GoogleFonts.mPlusRounded1c(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkTextSecondary,
        letterSpacing: -0.2,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.mPlusRounded1c(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkTextSecondary,
        letterSpacing: -0.1,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.mPlusRounded1c(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
        letterSpacing: 0.1,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: darkDividerColor,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkCardColor,
      side: BorderSide(color: darkDividerColor),
      labelStyle: GoogleFonts.mPlusRounded1c(
        color: darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  // レッスン画面用の統一デザインコンポーネント
  
  // 統一されたプログレスバー
  static Widget buildProgressBar({
    required double progress,
    double height = 4.0,
    Color? backgroundColor,
    Color? progressColor,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: backgroundColor ?? dividerColor,
      ),
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: progressColor ?? primaryColor,
          ),
        ),
      ),
    );
  }

  // 統一されたレッスンカード（よりポップで魅力的に）
  static Widget buildLessonCard({
    required Widget child,
    EdgeInsets? padding,
    Color? backgroundColor,
    VoidCallback? onTap,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isHighlighted 
          ? LinearGradient(
              colors: [primaryColor.withOpacity(0.1), secondaryColor.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
        color: !isHighlighted ? (backgroundColor ?? cardColor) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? primaryColor.withOpacity(0.3) : dividerColor, 
          width: isHighlighted ? 2 : 1
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted 
              ? primaryColor.withOpacity(0.2)
              : primaryColor.withOpacity(0.08),
            blurRadius: isHighlighted ? 12 : 8,
            offset: Offset(0, isHighlighted ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }

  // 統一された録音ボタン（より魅力的で動きのあるデザイン）
  static Widget buildRecordingButton({
    required bool isRecording,
    required bool isProcessing,
    required VoidCallback onPressed,
    double size = 60,
  }) {
    Color getButtonColor() {
      if (isProcessing) return warningColor;
      if (isRecording) return errorColor;
      return primaryColor;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            getButtonColor(),
            getButtonColor().withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: getButtonColor().withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          if (isRecording) 
            BoxShadow(
              color: errorColor.withOpacity(0.6),
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: Colors.white.withOpacity(0.3),
          child: Icon(
            isRecording ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }

  // 統一された音声再生ボタン
  static Widget buildPlayButton({
    required bool isPlaying,
    required VoidCallback onPressed,
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }

  // 統一された選択肢ボタン（よりポップで楽しいデザイン）
  static Widget buildChoiceButton({
    required String text,
    required bool isSelected,
    required bool isCorrect,
    required bool showResult,
    required VoidCallback onPressed,
    EdgeInsets? padding,
  }) {
    Color getBackgroundColor() {
      if (showResult) {
        if (isSelected) {
          return isCorrect ? successColor.withOpacity(0.15) : errorColor.withOpacity(0.15);
        } else if (isCorrect) {
          return successColor.withOpacity(0.15);
        }
      }
      return isSelected ? primaryColor.withOpacity(0.15) : cardColor;
    }

    Color getBorderColor() {
      if (showResult) {
        if (isSelected) {
          return isCorrect ? successColor : errorColor;
        } else if (isCorrect) {
          return successColor;
        }
      }
      return isSelected ? primaryColor : dividerColor;
    }

    Color getTextColor() {
      if (showResult) {
        if (isSelected) {
          return isCorrect ? successColor : errorColor;
        } else if (isCorrect) {
          return successColor;
        }
      }
      return isSelected ? primaryColor : textPrimary;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: getBorderColor(),
          width: 2,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: getBorderColor().withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: getBorderColor().withOpacity(0.1),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showResult && (isSelected || isCorrect))
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? successColor : errorColor,
                      size: 20,
                    ),
                  ),
                Flexible(
                  child: Text(
                    text,
                    style: GoogleFonts.mPlusRounded1c(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: getTextColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 統一されたスコア表示
  static Widget buildScoreIndicator({
    required double score,
    double size = 60,
    double strokeWidth = 6,
  }) {
    Color getScoreColor(double score) {
      if (score >= 80) return successColor;
      if (score >= 60) return warningColor;
      return errorColor;
    }

    final color = getScoreColor(score);
    final progress = (score / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            backgroundColor: dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '${score.round()}%',
            style: GoogleFonts.mPlusRounded1c(
              fontSize: size * 0.2,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 統一されたステータスチップ
  static Widget buildStatusChip({
    required String label,
    required bool isActive,
    VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? primaryColor.withOpacity(0.1) : cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? primaryColor : dividerColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: GoogleFonts.mPlusRounded1c(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? primaryColor : textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // スマホ画面用のレスポンシブ値
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) return baseSize * 0.9;
    if (screenWidth > 400) return baseSize * 1.1;
    return baseSize;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) return const EdgeInsets.all(12);
    return const EdgeInsets.all(16);
  }

  // 新しいポップなUIユーティリティ
  
  // グラデーション背景コンテナ
  static Widget buildGradientContainer({
    required Widget child,
    List<Color>? colors,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [primaryColor.withOpacity(0.1), secondaryColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  // ポップなアクションチップ
  static Widget buildPopChip({
    required String label,
    required Color color,
    VoidCallback? onTap,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: GoogleFonts.mPlusRounded1c(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ポップなプログレスインジケーター
  static Widget buildPopProgressIndicator({
    required double progress,
    double height = 8,
    List<Color>? colors,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: dividerColor,
      ),
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              colors: colors ?? [primaryColor, secondaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (colors?.first ?? primaryColor).withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // カラフルなバッジ
  static Widget buildColorfulBadge({
    required String text,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) {
    final bgColor = backgroundColor ?? popPink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.mPlusRounded1c(
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w700,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
} 
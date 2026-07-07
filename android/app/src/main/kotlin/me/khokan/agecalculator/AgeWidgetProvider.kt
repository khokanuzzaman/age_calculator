package me.khokan.agecalculator

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget showing the user's current age and days until their next
 * birthday. Data is pushed from Dart via the home_widget plugin; tapping the
 * widget opens the app.
 */
class AgeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.age_widget)

            val ageText = widgetData.getString("age_text", null) ?: "Set your birthday"
            val countdownText =
                widgetData.getString("countdown_text", null) ?: "Tap to open Age Calculator"

            views.setTextViewText(R.id.widget_age, ageText)
            views.setTextViewText(R.id.widget_countdown, countdownText)

            // Tapping anywhere on the widget opens the app.
            val pendingIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

package com.example.ej_geek

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class DashboardWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.dashboard_widget).apply {
                setTextViewText(R.id.widget_revenue, widgetData.getString("revenue", "A\$0"))
                setTextViewText(R.id.widget_pending_amount, widgetData.getString("pendingAmount", "A\$0"))
                setTextViewText(R.id.widget_paid_amount, widgetData.getString("paidAmount", "A\$0"))
                setTextViewText(R.id.widget_invoice_count, widgetData.getInt("invoiceCount", 0).toString())
                setTextViewText(R.id.widget_pending_count, widgetData.getInt("pendingCount", 0).toString())
                setTextViewText(R.id.widget_paid_count, widgetData.getInt("paidCount", 0).toString())
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

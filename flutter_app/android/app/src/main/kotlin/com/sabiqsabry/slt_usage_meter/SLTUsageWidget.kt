package com.sabiqsabry.slt_usage_meter

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.*

class SLTUsageWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"

        fun updateWidget(context: Context, manager: AppWidgetManager, widgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.slt_widget_layout)

            val subscriberId = prefs.getString("flutter.subscriber_id", null)

            if (subscriberId.isNullOrEmpty()) {
                // Not logged in
                views.setTextViewText(R.id.tv_subscriber, "SLT Usage Meter")
                views.setTextViewText(R.id.tv_status, "Login")
                views.setViewVisibility(R.id.row1, View.GONE)
            } else {
                val status = prefs.getString("flutter.status", "Unknown") ?: "Unknown"
                views.setTextViewText(R.id.tv_subscriber, subscriberId)
                views.setTextViewText(R.id.tv_status, status)

                val mainRows = parseRows(prefs, "flutter.main_usage")
                val bonusRow = parseSingleSummary(prefs, "flutter.bonus_data", "Bonus Data")
                val extraRow = parseSingleSummary(prefs, "flutter.extra_gb", "Extra GB")

                val allRows = (mainRows + listOfNotNull(bonusRow, extraRow)).take(3)

                val rowViews = listOf(R.id.row1, R.id.row2, R.id.row3)
                val barColors = listOf(0xFF2196F3.toInt(), 0xFF9C27B0.toInt(), 0xFFFF9800.toInt())

                allRows.forEachIndexed { i, row ->
                    views.setViewVisibility(rowViews[i], View.VISIBLE)
                    val rowView = RemoteViews(context.packageName, R.layout.widget_usage_row)
                    rowView.setTextViewText(R.id.tv_name, row.name)
                    val valueText = if (row.limit != null)
                        "${fmt(row.used)} / ${fmt(row.limit)} ${row.unit}"
                    else
                        "${fmt(row.used)} ${row.unit}"
                    rowView.setTextViewText(R.id.tv_value, valueText)
                    val progress = if (row.limit != null) {
                        val l = row.limit.toDoubleOrNull() ?: 0.0
                        val u = row.used.toDoubleOrNull() ?: 0.0
                        if (l > 0) ((u / l) * 100).toInt().coerceIn(0, 100) else 0
                    } else 0
                    rowView.setProgressBar(R.id.progress_bar, 100, progress, false)
                    rowView.setInt(R.id.progress_bar, "setProgressTintList",
                        android.content.res.ColorStateList.valueOf(barColors[i]).defaultColor)
                    views.addView(rowViews[i], rowView)
                }

                // Hide unused rows
                for (i in allRows.size until rowViews.size) {
                    views.setViewVisibility(rowViews[i], View.GONE)
                }
            }

            // Tap to open app
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (intent != null) {
                val pi = PendingIntent.getActivity(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pi)
            }

            // Last updated
            val lastUpdated = prefs.getString("flutter.last_updated", null)
            if (!lastUpdated.isNullOrEmpty()) {
                try {
                    val parsed = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                        .parse(lastUpdated.take(19))
                    val formatted = SimpleDateFormat("HH:mm", Locale.getDefault()).format(parsed!!)
                    views.setTextViewText(R.id.tv_updated, "Updated $formatted")
                } catch (_: Exception) {}
            }

            manager.updateAppWidget(widgetId, views)
        }

        private data class RowData(
            val name: String,
            val used: String,
            val limit: String?,
            val unit: String
        )

        private fun parseRows(prefs: SharedPreferences, key: String): List<RowData> {
            val json = prefs.getString(key, null) ?: return emptyList()
            return try {
                val arr = JSONArray(json)
                (0 until arr.length()).map { i ->
                    val obj = arr.getJSONObject(i)
                    RowData(
                        name = obj.optString("name"),
                        used = obj.optString("used", "0"),
                        limit = obj.optString("limit").takeIf { it.isNotEmpty() && it != "null" },
                        unit = obj.optString("volume_unit", "GB")
                    )
                }
            } catch (_: Exception) { emptyList() }
        }

        private fun parseSingleSummary(prefs: SharedPreferences, key: String, label: String): RowData? {
            val json = prefs.getString(key, null) ?: return null
            return try {
                val obj = org.json.JSONObject(json)
                RowData(
                    name = label,
                    used = obj.optString("used", "0"),
                    limit = obj.optString("limit").takeIf { it.isNotEmpty() && it != "null" },
                    unit = obj.optString("volume_unit", "GB")
                )
            } catch (_: Exception) { null }
        }

        private fun fmt(s: String): String {
            val d = s.toDoubleOrNull() ?: return s
            return if (d == kotlin.math.floor(d)) d.toInt().toString()
            else String.format("%.1f", d)
        }
    }
}

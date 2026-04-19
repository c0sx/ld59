# EventBus
extends Node


signal report_added(report_data: ReportData)

func emit_report_added(report_data: ReportData) -> void:
  report_added.emit(report_data)


signal report_skipped(report_data: ReportData)

func emit_report_skipped(report_data: ReportData) -> void:
  report_skipped.emit(report_data)


signal report_opened(report_data: ReportData)

func emit_report_opened(report_data: ReportData) -> void:
  report_opened.emit(report_data)


signal report_sent(report_data: ReportData)

func emit_report_sent(report_data: ReportData) -> void:
  report_sent.emit(report_data)


signal sleep_started()

func emit_sleep_started() -> void:
  sleep_started.emit()

signal sleep_ended()

func emit_sleep_ended() -> void:
  sleep_ended.emit()


signal event_analyzed(data: EventData)

func emit_event_analyzed(data: EventData) -> void:
  event_analyzed.emit(data)


signal anomaly_analyzed(data: EventData)

func emit_anomaly_analyzed(data: EventData) -> void:
  anomaly_analyzed.emit(data)


signal error_report_sent(data: ReportData, errors_amount: int)

func emit_error_report_sent(data: ReportData, errors_amount: int) -> void:
  error_report_sent.emit(data, errors_amount)


signal ok_report_sent(data: ReportData)

func emit_ok_report_sent(data: ReportData) -> void:
  ok_report_sent.emit(data)


signal game_over()

func emit_game_over() -> void:
  game_over.emit()


signal research_completed()

func emit_research_completed() -> void:
  research_completed.emit()


signal research_failed()

func emit_research_failed() -> void:
  research_failed.emit()


signal events_initialized(events: Array[EventData])

func emit_events_initialized(events: Array[EventData]) -> void:
  events_initialized.emit(events)


signal new_event(event_data: EventData)

func emit_new_event(event_data: EventData) -> void:
  new_event.emit(event_data)


signal brief_read

func emit_brief_read() -> void:
  brief_read.emit()

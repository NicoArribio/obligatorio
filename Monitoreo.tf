

# Alarma CPU alta
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "ob-asg-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2" # La métrica de CPU está en el namespace de EC2
  period              = 300 
  statistic           = "Average"
  threshold           = 70 # 70% de CPU
  actions_enabled     = true

  # Las acciones a tomar cuando la alarma cambia al estado ALARM
  # Las politicas estan establecidas en lb.tf
  alarm_actions = [aws_autoscaling_policy.ob_scale_up_policy.arn]

  # Las acciones a tomar cuando la alarma cambia al estado OK
  # Política de escalado descendente para volver al estado normal
  ok_actions = [aws_autoscaling_policy.ob_scale_down_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ob-asg.name # Asocia la alarma al ASG
  }

  tags = {
    Name = "OB-High-CPU-Alarm"
  }
}

# Alarma para CPU baja
resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "ob-asg-low-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30 # 30% de CPU
  actions_enabled     = true

  # Accion cuando la alarma cambia a estado ALARM
  # Referencia la política de escalado descendente
  alarm_actions = [aws_autoscaling_policy.ob_scale_down_policy.arn]

  # Accion a tomar cuando la alarma cambia al estado OK
  # política de escalado ascendente si la CPU sube del umbral bajo
  ok_actions = [aws_autoscaling_policy.ob_scale_up_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ob-asg.name
  }

  tags = {
    Name = "OB-Low-CPU-Alarm"
  }
}

# --- Salidas de Monitoreo  ---
output "high_cpu_alarm_arn" {
  description = "ARN of the high CPU CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.high_cpu_alarm.arn
}

output "low_cpu_alarm_arn" {
  description = "ARN of the low CPU CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.low_cpu_alarm.arn
}
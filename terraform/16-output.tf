output "efs-id-primary" {
  value = aws_efs_file_system.eks_primary.id
}

output "efs-id-backup" {
  value = aws_efs_file_system.eks_backup.id
}
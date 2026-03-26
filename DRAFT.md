For backups:

  1. Set up RBAC                                                                                                                                                                           
                                                                                                                                                                                           
  apiVersion: v1                                                                                                                                                                           
  kind: ServiceAccount                                                                                                                                                                     
  metadata:                                                                                                                                                                                
    name: tidb-backup-manager                                                                                                                                                              
    namespace: <your-tidb-namespace>
    # If using IRSA, add the annotation:
    # annotations:                                                                                                                                                                         
    #   eks.amazonaws.com/role-arn: arn:aws:iam::<account>:role/<backup-role>
                                                                                                                                                                                           
  2. Create a Backup CR when you want to back up                                                                                                                                           
                                                                                                                                                                                           
  apiVersion: br.pingcap.com/v1alpha1                                                                                                                                                      
  kind: Backup    
  metadata:
    name: agama-backup-20260326    # unique name per backup
    namespace: <your-tidb-namespace>                                                                                                                                                       
  spec:
    backupType: full                                                                                                                                                                       
    serviceAccount: tidb-backup-manager                                                                                                                                                    
    br:
      cluster: <your-tidb-cluster-name>   # from your TidbCluster CR                                                                                                                       
      sendCredToTikv: false               # false when using IRSA                                                                                                                          
    s3:                                                                                                                                                                                    
      provider: aws                                                                                                                                                                        
      region: <your-region>                                                                                                                                                                
      bucket: <your-backup-bucket>
      prefix: agama-backups/full
                                                                                                                                                                                           
  Apply it whenever you want: kubectl apply -f backup.yaml
                                                                                                                                                                                           
  3. Check status                                                                                                                                                                          
   
  kubectl get backup agama-backup-20260326 -n <namespace>                                                                                                                                  
  kubectl describe backup agama-backup-20260326 -n <namespace>
                                                                                                                                                                                           
  Key notes
                                                                                                                                                                                           
  - API group changed in v2: it's br.pingcap.com/v1alpha1 (not pingcap.com)                                                                                                                
  - EBS snapshots removed in v2 — only BR (distributed SST backup) and Dumpling (logical/SQL dump) are available
  - Auth options for S3: IRSA (recommended on EKS), or AccessKey/SecretKey via a Kubernetes Secret                                                                                         
  - For scheduled backups later, the workaround is a Kubernetes CronJob that creates Backup CRs — that's essentially what v1's BackupSchedule did internally                               
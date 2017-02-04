node {
   stage('Preparation') { 
      // Get some code from a GitHub repository
      git 'https://github.com/mcgonagle/terraform_f5.git'
   }
   stage('Build') {
      sh '/usr/local/bin/terraform apply'
      //chatops slack message that ansible run has completed
      slackSend( 
         channel: '#jenkins', 
         color: 'good', 
         message: 'Terraform Ran Successfully', 
         teamDomain: 'gridironops', 
         token: 'xoxp-133829851444-133839987205-134030684453-3ee4acd209578522e2f2e3e16a5d400a'
         )
   }
}

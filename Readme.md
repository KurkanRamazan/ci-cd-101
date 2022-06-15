# İçerik

## Amaç

CI/CD süreçlerinde kullanılan araçların kurulum ve çalışma şekillerinin anlaşılması. Devops ortam kurulumlarında yaşanan sıkıntıların daha net anlaşılabilmesi.

## Yapılacaklar

Yapılacak işler senaryolar üzerinden takip edilecektir.

## Uygulamalar ve Erişim Şekilleri

| Uygulama   | Erişim Şekli | Erişim Noktası  | admin user       | admin password            |
| ---------- | ------------ | --------------- | ---------------- | ------------------------- |
| PostgreSQL | TCP          | localhost:5432  | custom_user_root | custom_user_root_password |
| GoGs       | HTTP         | localhost:3000  | gogs-admin       | gogs-admin                |
| GoGs       | SSH          | localhost:10022 |
| Jenkins    | HTTP         | localhost:8080  | jenkins-admin    | jenkins-admin-password    |
| pure-ftpd  | FTP          | localhost:10021 | ftpuser          | ftpuser-password          |

## Senaryolar

### Senaryo 1 - Git ortam kurulumu (YAPILDI)

#### Senaryo 1 - Amaç

Yazılan kodların saklanabileceği bir ortam hazılamak.

#### Senaryo 1 - Yapılanlar

1. Git server kurulumu

   1. Git server olarak kullanılacak ürün kararlaştırılması
      [https://www.cyberciti.biz/open-source/github-alternatives-open-source-seflt-hosted/](https://www.cyberciti.biz/open-source/github-alternatives-open-source-seflt-hosted/)

      | Ad           | Açıklama |
      | ------------ | -------- |
      | GoGs         | -------- |
      | Gitea        | -------- |
      | GNU Savannah | -------- |
      | GitBucket    | -------- |
      | ...          | -------- |

   1. Kurulumu ve kullanımı kolay olduğu için GoGs kullanılacaktır.

   1. GoGs docker-compose dosyası yazılacaktır.
      1. GoGs çalışabilmesi için PostgreSQL gerekmektedir.
      1. Kurulumların otomatikleştirilebilmesi için yardımcı scriptler kullanılacaktır
   1. Gogs admin gogs-admin ve gogs-admin-password olarak ayarlanmıştır
   1. Gogs arayüz [http://localhost:3000/](http://localhost:3000/)
   1. İlk kurulum sonrası oluşan "app.ini" dosyası ileriki kurulumlarda kullanılabilmesi için kopyalandı.
      1. app.ini dosyası admin kullanıcı oluşturmayı sağlamıyor.

### Senaryo 2 - Otomasyon Server Kurulumu (Yapıldı)

#### Senaryo 2 - Amaç

Sürekli entegrasyon (CI) sürecini otomatik bir şekilde gerçekleştirmek için bir eylemler zincirini düzenlemek için kurulacak sunucudur.

#### Senaryo 2 - Yapılanlar

1. CI server kurulumu

   1. CI server olarak kullanılacak ürün kararlaştırılması
      [https://www.guru99.com/jenkins-alternative.html](https://www.guru99.com/jenkins-alternative.html)

      | Ad            | Açıklama |
      | ------------- | -------- |
      | Buddy         | -------- |
      | Final builder | -------- |
      | CruiseControl | -------- |
      | Integrity     | -------- |
      | GoCD          | -------- |
      | Jenkins       | -------- |
      | ...           | -------- |

   1. Kurulumu ve kullanımı kolay olduğu için Jenkins kullanılacaktır.

   1. Jenkins docker-compose dosyası yazılacaktır.
   1. Jenkins arayüzü [http://localhost:8080/](http://localhost:8080/)
   1. İlk kurulum esnasında secret veriyor: 5d687f9fd7af4b03a4b7a2c30a9c257c
   1. İlk kurulum esnasında önerilen pluginler kuruldu.
   1. Kurulum yapılan server üzerinde build yapılması önerilmiyor.
      1. Bunun yerine build işlemleri distributed sistem üzerinde yapılması öneriliyor.
   1. [https://naiveskill.com/jenkins-pipeline-functions/](https://naiveskill.com/jenkins-pipeline-functions/)

      ```Groovy
        // Pipeline jenkins-101
        def Greet(name) {
            echo "Hello ${name}"
        }
        node {
            stage('Hello') {
                Greet('NaiveSkill')
            }
            stage('Write $BUILD_ID to file') {
                sh 'echo version := 1.0.$BUILD_ID >> version.txt'
            }
            stage('Clean workspace if $BUILD_ID % 3 = 0') {
                if(env.BUILD_ID.toInteger() % 3 == 0) {
                    echo 'Running cleanWs()'
                    cleanWs()
                }
            }
        }
      ```

### Senaryo 3 - Jenkins ve GoGs iletişimi (Yapıldı)

#### Senaryo 3 - Yapılacaklar

1. Örnek bir repository oluştur
1. Jenkins içerisinde bu repository için job oluştur.
1. Repository ye push yapıldığında yada belli aralıklarla yeni kod kontrolü yapılmalı ve job çalıştırılmalı
   1. Jenkins job periodik olarak yada manuel çalıştırılabilir. Her push/pr sonrası çalıştırılabilmesi sonraki senaryolarda yapılacaktır.

[https://medium.com/@salohyprivat/getting-gogs-and-jenkins-working-together-5e0f21377bcd](https://medium.com/@salohyprivat/getting-gogs-and-jenkins-working-together-5e0f21377bcd)

#### Senaryo 3 - Yapılanlar

1. GoGs içerisinde örnek bir repository oluşturuldu

   1. [http://localhost:3000/gogs-admin/repository-101](http://localhost:3000/gogs-admin/repository-101)

      ```text
        Create a new repository on the command line
        touch README.md
        git init
        git add README.md
        git commit -m "first commit"
        git remote add origin http://localhost:3000/gogs-admin/repository-101.git
        git push -u origin master

        Push an existing repository from the command line
        git remote add origin http://localhost:3000/gogs-admin/repository-101.git
        git push -u origin master

        HTTP: http://localhost:3000/gogs-admin/repository-101.git
        SSH : git@localhost:gogs-admin/repository-101.git
      ```

   1. İlk push sonrası master branch oluştu.
      1. Push esnasında kullanıcı adı vve şifresi girmem istendi
   1. Jenkins te ve GoGs da kullanılmak üzere ssh key oluştur

      1. Key oluştur

         ```bash
            ssh-keygen -t rsa -b 4096 -C "gogs-admin@localhost.com"
         ```

      1. Jenkins credentials eklenmeli
         1. Credential id herhangi bir şey olabilir: SomeIdForJenkinsToAccessGogs
         1. Username: gogs-admin
         1. Private key (ci_cd_key_rsa) jenkins içerisinde kullanılacak
      1. GoGs credentials eklenmeli
         1. GoGs kullanıcı ayarlarına gidilir.
         1. "SSH Keys" menüsüne gidilir.
         1. Buraya public key(ci_cd_key_rsa.pub) eklenir. Name: SomeIdForJenkinsToAccessGogs
      1. Jenkins içerisinde yeni bir item luşturulur

         1. Multibranch Pipeline
         1. "Scan Multibranch Pipeline Triggers" bölümü sayesinde belirli aralıklarla kod kontrolü yapılabilir.
         1. "Branch Sources" bölümünde "Add source" ile "Git" seçilir.
            1. Repository: [http://localhost:3000/gogs-admin/repository-101.git](http://localhost:3000/gogs-admin/repository-101.git)
            1. Credentials: SomeIdForJenkinsToAccessGogs (Girilen açıklama gözükebilir)
         1. Normal şartlarda bu aşamada repository içerisinde "Jenkinsfile" dosyası olmalıdır.  
            Test için repository e bu dosya eklenmemiştir.
         1. Hata alındı

            ```text
                Started
                [Wed Jun 08 20:54:29 UTC 2022] Starting branch indexing...
                > git --version # timeout=10
                > git --version # 'git version 1.8.3.1'
                using GIT_SSH to set credentials An id to use in jenkins for an ssh key to access gogs. The id does not really matter. Should be unique in jenkins
                > git ls-remote http://localhost:3000/gogs-admin/repository-101.git # timeout=10
                ERROR: [Wed Jun 08 20:54:30 UTC 2022] Could not update folder level actions from source 22e1d3e4-9bef-4f06-9a90-d7a6ebb335da
                [Wed Jun 08 20:54:30 UTC 2022] Finished branch indexing. Indexing took 0.18 sec
                FATAL: Failed to recompute children of git-repository-101
                hudson.plugins.git.GitException: Command "git ls-remote http://localhost:3000/gogs-admin/repository-101.git" returned status code 128:
                stdout:
                stderr: fatal: unable to access 'http://localhost:3000/gogs-admin/repository-101.git/': Failed to connect to ::1: Cannot assign requested address

                    at org.jenkinsci.plugins.gitclient.CliGitAPIImpl.launchCommandIn(CliGitAPIImpl.java:2671)
                    at org.jenkinsci.plugins.gitclient.CliGitAPIImpl.launchCommandWithCredentials(CliGitAPIImpl.java:2096)
                    at org.jenkinsci.plugins.gitclient.CliGitAPIImpl.launchCommandWithCredentials(CliGitAPIImpl.java:1996)
                    at org.jenkinsci.plugins.gitclient.CliGitAPIImpl.launchCommandWithCredentials(CliGitAPIImpl.java:1987)
                    at org.jenkinsci.plugins.gitclient.CliGitAPIImpl.getRemoteReferences(CliGitAPIImpl.java:3603)
                    at jenkins.plugins.git.AbstractGitSCMSource.retrieveActions(AbstractGitSCMSource.java:1170)
                    at jenkins.scm.api.SCMSource.fetchActions(SCMSource.java:848)
                    at jenkins.branch.MultiBranchProject.computeChildren(MultiBranchProject.java:598)
                    at com.cloudbees.hudson.plugins.folder.computed.ComputedFolder.updateChildren(ComputedFolder.java:278)
                    at com.cloudbees.hudson.plugins.folder.computed.FolderComputation.run(FolderComputation.java:166)
                    at jenkins.branch.MultiBranchProject$BranchIndexing.run(MultiBranchProject.java:1032)
                    at hudson.model.ResourceController.execute(ResourceController.java:101)
                    at hudson.model.Executor.run(Executor.java:442)
                Finished: FAILURE
            ```

         1. Hata çözümü için:
            1. docker-compose tanımlarında gogs ve jenkins in aynı network içerisinde olduğuna emin olunmalı.
            1. Repository linkindeki "localhost" yerine docker-compose daki service adı kullanılmalı
            1. Düzeltme sonrası "Scan Multibranch Pipeline" başarılı olmalı
         1. Bu aşamada jenkins projesinin ön yüzünde şu şekilde uyarı görülecektir.

            ```text
                This folder is empty
                There are no branches found that contain buildable projects.
            ```

            Kısaca bu uyarı: Hedef branch ta "Jenkinsfile" bulunamadı.

            ```Groovy
                // Pipeline repository-101
                def Greet(name) {
                    echo "Hello -${name}-"
                }
                node {
                    stage('Hello') {
                        Greet(env.JOB_NAME)
                        // Greet(env.BRANCH_NAME) // test branchta kullanılabilir
                        // Output:
                        // Hello -git-repository-101/a-test-branch- // env.JOB_NAME
                        // Hello -a-test-branch-                    // env.BRANCH_NAME
                    }
                    stage('Build') {
                        echo "Gonna run build commands here"
                    }
                }
            ```

         1. Jenkinsfile eklenip "Scan Multibranch Pipeline Now" çalıştırıldığında master branch a ait job gelecektir.
         1. Örnek ayarlarda değişiklikler 1 dakikalık periyodlar ile kontrol edilecek şekilde yapılmıştı. Yeni bir branch oluşturulup 1 dakika beklendiğinde yeni branch a ait jenkins job listeye gelmelidir.
         1. Her push/pr sonrası jenkins jobı çalıştırılması isteniyorsa "web hooks" özelliği aktif edilmelidir.
            1. Bu geliştirme için jenkins e GoGs plugin i kurulmalı ve ekstra ayarlar yapılmalıdır. Her push/pr sonrası jobın otomatik tetiklnmesi şu anda önemli olmadığı için gerçekleştirimi ilerleyen senaryolara bırakılmıştır.

### Senaryo 4 - Jenkins git checkout, build ve publish (Yapıldı)

#### Senaryo 4 - Yapılanlar

1. Git repository sini checkout yap

   ```Groovy
    stage('Checkout') {
            checkout scm
        }
   ```

1. Dummy build step hazırla

   ```bash
       #./repository-101/foo-make.sh
       #!/bin/bash
       if [ -d "dist" ]; then rm -Rf dist; fi
       mkdir dist
       echo $RANDOM | md5sum > dist/generated_file.txt
       cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 5 >> dist/generated_file.txt
   ```

   ```Groovy
       stage('Build') {
           echo "Execute foo-make.sh"
           sh "bash foo-make.sh"
       }
   ```

1. dist klasörünü zip le yada tar.gz yap

   ```Groovy
        stage('Generate artifacts(zip)') {
            sh "rm 'dist.tar.gz' 2> /dev/null  || true"
            sh '''
                tar -zcf dist.tar.gz dist
            '''
            archiveArtifacts artifacts: 'dist.tar.gz', fingerprint: true // bu adıma gerek yok
            archiveArtifacts artifacts: 'dist/', fingerprint: true // bu adıma gerek yok
        }
   ```

1. Jenkinsfile içerisinde bir adımı atlamak istiyorsak if/else/when yapılarını kullanabiliriz

   ```Groovy
        stage('Generate artifacts(zip)') {
            if (["master", "dev"].contains(env.BRANCH_NAME)){
                sh "rm 'dist.tar.gz' 2> /dev/null  || true"
                sh '''
                    tar -zcf dist.tar.gz dist
                '''
                archiveArtifacts artifacts: 'dist.tar.gz', fingerprint: true
                archiveArtifacts artifacts: 'dist/', fingerprint: true
                sh "ls -la ${pwd()}"
            } else {
                echo "Skip the branch ${env.BRANCH_NAME}"
            }
        }
        // yada
        stage('Generate artifacts(zip)') {
            if (!["master", "dev"].contains(env.BRANCH_NAME)){
                echo "Skip the branch ${env.BRANCH_NAME}"
                return
            }
            sh "rm 'dist.tar.gz' 2> /dev/null  || true"
            sh '''
                tar -zcf dist.tar.gz dist
            '''
            archiveArtifacts artifacts: 'dist.tar.gz', fingerprint: true
            archiveArtifacts artifacts: 'dist/', fingerprint: true
            sh "ls -la ${pwd()}"
        }
   ```

1. Jenkinsfile hata vermek için `error` methodu kullanılabilir.

   ```Groovy
        stage('Error example') {
            error("Aborting the build.")
        }
   ```

1. Jenkinsfile build işlemini durdurmak/abort etmek için:

   ```Groovy
        stage('Abort example') {
            currentBuild.result = 'ABORTED'
            error("Aborting the build.")
        }
   ```

1. Basit bir deployment sisteminin oluşturulması

   1. Ftp server a upload et yada herhangi bir dizine kopyala
   1. Örnek olması açısından docker-compose içerisine ftp-servr kuruldu.
      Bu ftp-server herhangi bir deployment ortamı gibi düşünebiliriz.
      IIS, nginx, remote docker v.b. işlemlerde yapılabilirdi.
   1. Neden ftp?
      1. En temel seviyede bir deployment işlemi aslında oluşan ürün dosyalarının (artifacts/zip/dll/exe...)
         ürünün çalışacağı ortama aktarılabilmesidir. Oluşan ürün dosyalarını basitçe jenkins içerisinden
         host bilgisayardaki klasörlere aktarmak en basit seviyede bir deployment işlemidir.
         Ancak, jenkins ile remote deployment nasıl yapılabilir sorusuna basitçe cevap verebilmek adına ftp sunucusuna dosya yüklemek
         tercih edilmiştir.
      1. Buradaki ftp sunucusu host üzerinde çalışmak zorunda değildir. Örnek olması açısından docker-compose a eklenmiştir.
   1. FTP server bilgileri

      | Key      | Value            |
      | -------- | ---------------- |
      | Host     | localhost        |
      | Port     | 21               |
      | Username | ftpuser          |
      | Password | ftpuser-password |

   1. FTP işlemleri için jenkins e "Publish Over FTP" plugin i kurulmuştur.

      1. FTP sunucusunu jenkins içerisinden kullanabilmek için jenkins configuration alanındaki "Publish over FTP" bölümünde "Ftp Server" eklemesi yapılır.

      | Key                  | Value                                                |
      | -------------------- | ---------------------------------------------------- |
      | Name                 | localhost-ftp-server                                 |
      | Hostname             | ftp-server (docker-compose-service-name)             |
      | Username             | ftpuser                                              |
      | Password             | ftpuser-password                                     |
      | Remote Directory     | /repository-101                                      |
      | Use active data mode | checked (Advanced options)(PASV bağlantı çalışmazsa) |

   1. master ve dev branch ları artifact üretecektir.

      1. Artifact olarak arşiv dosyası üretilecektir.
      1. Arşiv dosyasının ismi "dist-&lt;jenkins-build-id&gt;.tar.gz" şeklinde olacaktır.
      1. zip dosyası "dist" isimli klasör altında oluşturulacaktır.

         ```Groovy
                stage('Generate artifacts(zip)') {
                    if (!["master", "dev"].contains(env.BRANCH_NAME)){
                        echo "Skip the branch ${env.BRANCH_NAME}"
                        return;
                    }
                    sh "rm '*.tar.gz' 2> /dev/null  || true"
                    sh "tar -zcf dist-${env.BUILD_ID}.tar.gz dist"
                    archiveArtifacts artifacts: "dist-${env.BUILD_ID}.tar.gz", fingerprint: true
                }
         ```

   1. Jenkinsfile içerisinde ftp methodunu çağırmak
      [https://stackoverflow.com/questions/41174045/using-jenkins2-pipeline-to-upload-via-ftp](https://stackoverflow.com/questions/41174045/using-jenkins2-pipeline-to-upload-via-ftp)

      ```Groovy
          stage('Upload')
          {
              ftpPublisher alwaysPublishFromMaster: true, continueOnError: false, failOnError: false, publishers: [
                  [configName: 'localhost-ftp-server', transfers: [
                      [asciiMode: false, cleanRemote: false, excludes: '', flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: "/repository-101/${env.BRANCH_NAME}", remoteDirectorySDF: false, removePrefix: '', sourceFiles: '**.tar.gz, **.tar.gz2']
                  ], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true]
              ]
          }
      ```

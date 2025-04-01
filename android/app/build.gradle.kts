plugins {
    id "com.android.application"
    id "kotlin-android"
    id 'com.google.gms.google-services'
    id "dev.flutter.flutter-gradle-plugin"
}

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.rohit.settlenow"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.rohit.settlenow"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
       release {
           keyAlias keystoreProperties['keyAlias']
           keyPassword keystoreProperties['keyPassword']
           storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
           storePassword keystoreProperties['storePassword']
       }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }

    flavorDimensions "default"

    productFlavors {
        prod {
            dimension "default"
        }
        dev {
            dimension "default"
            applicationIdSuffix ".dev"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
  implementation platform('com.google.firebase:firebase-bom:33.9.0')
  implementation 'com.google.firebase:firebase-analytics'
  implementation 'com.android.support:multidex:1.0.3'
  implementation 'com.google.android.recaptcha:recaptcha:18.4.0'
  implementation 'com.google.firebase:firebase-perf'
  implementation 'androidx.activity:activity:1.6.0-alpha05'
  implementation 'com.google.android.play:integrity:1.4.0'
}

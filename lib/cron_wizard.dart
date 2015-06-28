library cron_wizard;

import 'dart:math' as math;
import 'package:angular/angular.dart';

part 'src/field.dart';
part 'src/wizard.dart';

class CronWizardModule extends Module {
  CronWizardModule() {
    bind(CronField);
    bind(CronWizard);
  }
}


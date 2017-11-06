part of cron_wizard;

@Component(
    selector: 'cron-wizard',
    templateUrl: 'packages/cron_wizard/src/wizard.html',
    useShadowDom: false)
class CronWizard {
  NgModel model;
  NgForm form;
  String _interval;
  String _value;
  String _minute, _hour, _day, _month, _dow; // fields in cron format
  bool invalid = true;

  static int idCounter = 0;
  final int id;
  
  final RegExp _reCron = new RegExp("^((?:\\*|(?:[0-9\\-\\,]+))(?:/\\d+)?)\\s+((?:\\*|(?:[0-9\\-\\,]+))(?:/\\d+)?)\\s+((?:\\*|(?:[0-9\\-\\,]+))(?:/\\d+)?)\\s+((?:\\*|(?:[0-9\\-\\,]+))(?:/\\d+)?)\\s+((?:\\*|(?:[0-9\\-\\,]+))(?:/\\d+)?)\\s*\$");
  
  CronWizard(this.model, this.form) :
    id = idCounter++
  {
    this.model.render = render; 
  }
  
  bool get anyFieldInvalid {
    if(form == null)
      return false;
    ["minute","hour","day","month","dow"].forEach((_) { if(form[_] != null && form[_].invalid) return true; });
    return false;
  }
  
  String get value => _value;
  void set value(String value) {
    _value = value;
    model.viewValue = value;
  }
  
  String get minute => _minute;
  void set minute(String value) {
    _minute = value;
    updateModel();
  }
  
  String get hour => _hour;
  void set hour(String value) {
    _hour = value;
    updateModel();
  }
  
  String get day => _day;
  void set day(String value) {
    _day = value;
    updateModel();
  }
  
  String get month => _month;
  void set month(String value) {
    _month = value;
    updateModel();
  }
  
  String get dow => _dow;
  void set dow(String value) {
    _dow = value;
    updateModel();
  }
  
  void render(dynamic newValue) {
    if(newValue is String && _reCron.matchAsPrefix(newValue) != null) {
      value = newValue;
      Match m = _reCron.matchAsPrefix(value);
      _minute = m.group(1);
      _hour = m.group(2);
      _day = m.group(3);
      _month = m.group(4);
      _dow = m.group(5);
      _interval = "$minute $hour $day $month $dow";
      invalid = false;
    }
    else {
      _interval = newValue;
      invalid = true;
    }
  }
  
  void updateModel() {
    interval = model.viewValue = "$minute $hour $day $month $dow";
  }
  
  String get interval => _interval;
  void set interval(String value) {
    render(value);
  }
}

part of cron_wizard;

@Component(
    selector: 'cron-wizard',
    templateUrl: 'src/wizard.html',
    directives: const [CORE_DIRECTIVES, materialDirectives, formDirectives, CronField],
    providers: const [materialProviders],
)
class CronWizard {
  NgModel model;
  NgForm form;
  String _interval;
  String _value;
  String _minute, _hour, _day, _month, _dow; // fields in cron format
  bool invalid = true;

  bool showCollapse = false;

  List<String> months = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'];
  List<String> days   = ['sun','mon','tue','wed','thu','fri','sat','sun'];
  static int idCounter = 0;
  final int id;

  final RegExp _reCron = new RegExp("^((?:\\*|(?:[0-9\\-\\,]+))(?:/\\d+)?)\\s+((?:\\*|(?:[0-9\\-\\,]+))(?:/\\d+)?)\\s+((?:\\*|(?:[0-9\\-\\,]+))(?:/\\d+)?)\\s+((?:\\*|(?:[0-9\\-\\,]+))(?:/\\d+)?)\\s+((?:\\*|(?:[0-9\\-\\,]+))(?:/\\d+)?)\\s*\$");

  CronWizard(this.model, this.form) :
    id = idCounter++
  {}


  @Input("crontab")
  void set crontab(String val) {
    interval = val;
  }

  final _crontabChange = new StreamController<String>();
  @Output("crontabChange")
  String get crontabChange => _crontabChange.stream;


  String get interval => _interval;
  void set interval(String value) {
    render(value);
  }

  bool get anyFieldInvalid {
    if(form == null)
      return false;
    ["minute","hour","day","month","dow"].forEach((_) { if(form != null) return true; });
    return false;
  }

  String get value => _value;
  void set value(String value) {
    _value = value;
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
    interval = "$minute $hour $day $month $dow";
    _crontabChange.add(interval);
  }
}

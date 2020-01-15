part of cron_wizard;

@Component(
    selector: 'cron-field',
    templateUrl: 'src/field.html',
    directives: const [CORE_DIRECTIVES, materialDirectives, formDirectives, materialNumberInputDirectives],
    providers: const [materialProviders],
)
class CronField {
  static const int _RT_EVERY = 0, _RT_FIXED = 1, _RT_LIST = 2, _RT_RANGE = 3;
  NgForm form;


  int get RT_EVERY => _RT_EVERY;
  int get RT_FIXED => _RT_FIXED;
  int get RT_LIST => _RT_LIST;
  int get RT_RANGE => _RT_RANGE;
  
  @Input("range-low")
  int rangeLow;
  
  @Input("range-high")
  int rangeHigh;
  
  @Input("field-name")
  String name;
  
  List<String> _names;
  List<int> namesRange;
  String shortNames;

  String _value;
  get value => _value;
  set value(String val) => _value = val;

  @Input("names")
  void set names(List<String> value) {
    _names = value;
    int i = 0;
    namesRange = value.map((_) => i++).toList(growable: false);
    if(value.length >= 4)
      shortNames = "${value[0]}, ${value[1]}, ${value[2]}, ... ${value.last}";
    else
      shortNames = value.join(", ");
  }

  @Input("model_value")
  void set model_value(String val) {
    _value = val;
    this.render(_value);
  }

  final _valueStream = new StreamController<String>();
  @Output()
  String get model_value => _valueStream.stream;
  
  List<String> get names => _names;
  
  bool get needsRecurrenceValue => (recurrenceType == RT_LIST || recurrenceType == RT_RANGE);
  
  int _recurrenceType = _RT_EVERY;
  String _recurrenceList;
  int _recurrenceFixed;
  int _recurrenceRangeLow, _recurrenceRangeHigh;
  bool _enOnlyEach = false;
  int _onlyEach = 2;
  
  int get recurrenceType => _recurrenceType;
  void set recurrenceType(int value) {
    _recurrenceType = value;
    if(_recurrenceType == _RT_FIXED)
      _enOnlyEach = false;
    updateModel();
  }
  
  int get recurrenceFixed => _recurrenceFixed;
  void set recurrenceFixed(int value) {
    _recurrenceFixed = value;
    updateModel();
  }

  String get recurrenceList => _recurrenceList;
  void set recurrenceList(String value) {
    _recurrenceList = value;
    updateModel();
  }
  
  int get recurrenceRangeLow => _recurrenceRangeLow;
  void set recurrenceRangeLow(int value) {
    _recurrenceRangeLow = value;
    updateModel();
  }

  int get recurrenceRangeHigh => _recurrenceRangeHigh;
  void set recurrenceRangeHigh(int value) {
    _recurrenceRangeHigh = value;
    updateModel();
  }

  bool get enOnlyEach => _enOnlyEach;
  void set enOnlyEach(bool value) {
    _enOnlyEach = value;
    updateModel();
  }
  
  int get onlyEach => _onlyEach;
  void set onlyEach(int value) {
    _onlyEach = value;
    updateModel();
  }
  
  int get recurrenceRangeLowMax => recurrenceRangeHigh == null ? rangeHigh : math.min(rangeHigh, recurrenceRangeHigh);
  int get recurrenceRangeHighMin => recurrenceRangeLow == null ? rangeLow : math.max(rangeLow, recurrenceRangeLow);
  
  CronField(this.form) {

  }
  
  bool invalid = true;
  
  final RegExp _reCrude = new RegExp("^([^/]+)(?:/(\\d+))?\$");
  final RegExp _reRange = new RegExp("^(?:(?:(\\d+)(?:-(\\d+))?)|(\\*))\$");
  
  bool inRange(num a, num l, num h) => a >= l && a <= h;
  
  void render(dynamic newValue) {
    invalid = !(newValue is String);
    if(!invalid) {
      Match mCrude = _reCrude.matchAsPrefix(newValue);
      invalid = (mCrude == null);
      if(!invalid) {
        String sList = mCrude.group(1);
        String sEach = mCrude.group(2);
        
        Iterable<String> ranges = sList.split(",").map((_) => _.trim());
        invalid = ranges.firstWhere((_) => _reRange.matchAsPrefix(_) == null, orElse: () => null) != null;
        if(!invalid) {
          if(ranges.length == 1) {
            Match m = _reRange.matchAsPrefix(ranges.first);
            if(m.group(1) != null) {
              if(m.group(2) != null) {
                _recurrenceRangeLow = int.parse(m.group(1));
                _recurrenceRangeHigh = int.parse(m.group(2));
                _recurrenceType = _RT_RANGE;
                invalid = !inRange(_recurrenceRangeLow, rangeLow, rangeHigh) || !inRange(_recurrenceRangeHigh, rangeLow, rangeHigh);
              }
              else {
                if(_recurrenceType != _RT_LIST){
                  _recurrenceFixed = int.parse(m.group(1));
                  _recurrenceType = _RT_FIXED;
                  invalid = !inRange(_recurrenceFixed, rangeLow, rangeHigh);
                }
              }
            }
            else
              _recurrenceType = _RT_EVERY;
          }
          else {
            _recurrenceList = ranges.join(",");
            _recurrenceType = _RT_LIST;
          }
        }
        
        _enOnlyEach = (sEach != null);
        if(_enOnlyEach)
          _onlyEach = int.parse(sEach);
      }
    } else {
      //invalid
      _value = null;
      _valueStream.add(_value);
    }
  }
  
  void updateModel([bool emit = true]) {
    String val;
    switch(recurrenceType) {
      case _RT_EVERY:
        val = "*";
        break;
      case _RT_FIXED:
        val = recurrenceFixed?.toStringAsFixed(0);
        break;
      case _RT_RANGE:
        val = "${recurrenceRangeLow?.toStringAsFixed(0)}-${recurrenceRangeHigh?.toStringAsFixed(0)}";
        break;
      case _RT_LIST:
        val = recurrenceList;
        break;
    }
    
    if(enOnlyEach)
      val += "/${onlyEach?.toStringAsFixed(0)}";

    if(emit){
      _value = val;
      _valueStream.add(_value);
    }

    invalid = false;
  }
  
  String get reductionPostfix => onlyEach == null ? null : _positionPostfix(onlyEach);
  
  String _positionPostfix(int n) {
    if(n == 1)
      return "st";
    else if(n == 2)
      return "nd";
    else if(n == 3)
      return "rd";
    else if(n <= 20)
      return "th";
    else
      return _positionPostfix(n % 10);
  }
}

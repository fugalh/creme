require 'test/unit'
require 'at_time'

class TestAtTime < Test::Unit::TestCase
  # hms is [hours, minutes, seconds]
  def assert_time(t1, t2)
    assert_equal t1.hour, t2.hour
    assert_equal t1.min, t2.min
    assert_equal t1.sec, t2.sec
  end
  def assert_datetime(t1, t2)
    assert_equal t1.year, t2.year
    assert_equal t1.month, t2.month
    assert_equal t1.day, t2.day
    assert_time(t1, t2)
  end

  def setup
    $now = Time.now
  end

  # time = [H]HMM[.SS] [am|pm] | [H]H:MM[.SS] [am|pm] | midnight | noon | teatime
  def test_parse_time
    assert_equal [0,0,0,''], AtTime.parse_time('midnight')
    assert_equal [12,0,0,''], AtTime.parse_time('noon')
    assert_equal [16,0,0,''], AtTime.parse_time('teatime')
    assert_equal [16,0,0,''], AtTime.parse_time('tea')
    assert_equal [16,10,0,''], AtTime.parse_time('1610')
    assert_equal [16,1,0,''], AtTime.parse_time('4:01 pm')
    assert_equal [10,3,10,''], AtTime.parse_time('10:03.10 am')
    assert_equal [11,3,5,''], AtTime.parse_time('1103.5')
    assert_equal [23,0,0,''], AtTime.parse_time('11pm')
  end

  # date = month-name day | DD.MM.YY[YY] | MM/DD/YY[YY] | MMDDYY[YY] | today | tomorrow
  def test_parse_date
    assert_equal [$now.year,2,21], AtTime.parse_date('February 21')
    assert_equal [$now.year,2,21], AtTime.parse_date('feb 21')
    assert_equal [1977,12,15], AtTime.parse_date('12/15/1977')
    assert_equal [2077,12,15], AtTime.parse_date('12/15/77')
    assert_equal [2008,2,21], AtTime.parse_date('2008-2-21')
  end

  # timespec = time [date] | [now] + count units
  def test_parse_timespec
    assert_time $now, AtTime.parse_timespec($now.strftime("%H%M.%S"))
    assert_datetime $now, AtTime.parse_timespec($now.strftime("%H%M.%S %d.%m.%Y"))
    assert_equal (Time.now + 5).sec, AtTime.parse_timespec('+5s').sec
    assert_equal (Time.now + 5*60).min, AtTime.parse_timespec('now + 5 min').min
  end

  # POSIX = [[CC]YY]MMDDhhmm[.SS]
  def test_parse_posix
    assert_datetime $now, AtTime.parse_posix($now.strftime("%m%d%H%M.%S"))
    assert_datetime $now, AtTime.parse_posix($now.strftime("%y%m%d%H%M.%S"))
    assert_datetime $now, AtTime.parse_posix($now.strftime("%Y%m%d%H%M.%S"))
  end
end

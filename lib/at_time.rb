require 'time'

# Parse at-compatible (but better) time specifications
module AtTime
  class ParseError < RuntimeError; end

  # [[CC]YY]MMDDhhmm[.SS]
  def self.posix(str)
    str.strip!
    unless str =~ /((\d\d)?\d\d)?(\d\d)(\d\d)(\d\d)(\d\d)(\.(\d\d))?/
      raise ArgumentError, "Invalid timespec"
    end
    t = Time.now
    if $1
      year = $2
    elsif $2
      year = "#{t.year/100}" + $2
    else
      year = t.year
    end
    seconds = $7 or '00'

    self.class.iso8601(sprintf("%s-%s-%sT%s:%s:%s", 
                               year, $3, $4, $5, $6, seconds))
  end

  # timespec = time [date] | [now] + count units
  def self.parse_timespec(str)
    # [now] + count units
    if str =~ /^\s*(now|(now)?\s*\+\s*(\d+)\s*([a-z]+))\s*$/i
      return Time.now if $1 == 'now'

      count = $3.to_i

      # units = seconds | minutes | hours | days | weeks | months | years
      ary = %w(seconds minutes hours days weeks months years).select{|x| x =~ /^#{$4}/i }
      raise ParseError, "Invalid unit" if ary.empty?
      unit = ary[0]

      now = Time.now
      case unit
      when 'seconds'
        now + count
      when 'minutes'
        now + count * 60
      when 'hours'
        now + count * 60 * 60
      when 'days'
        now + count * 60 * 60 * 24
      when 'weeks'
        now + count * 60 * 60 * 24 * 7
      when 'months'
        ary = now.to_a
        ary[4] += count
        ary[5] += ary[4]/12
        ary[4] %= 12
        puts ary.inspect
        Time.local(*ary)
      when 'years'
        ary = now.to_a
        ary[5] += count
        puts ary.inspect
        Time.local(*ary)
      end
    else
      # time [date]
      h,mi,s,str = parse_time(str)
      now = Time.now
      if str.strip == ""
        y,mo,d = [now.year, now.month, now.day]
        t = Time.mktime(y,mo,d,h,mi,s,0)
        if t - Time.now < 0
          t += 60*60*24
        end
        t
      else
        y,mo,d = parse_date(str)
        t = Time.mktime(y,mo,d,h,mi,s,0)
      end
    end
  end

  # time = [H]HMM[.SS] [am|pm] | [H]H:MM[.SS] [am|pm] | midnight | noon | teatime
  def self.parse_time(str)
    h = m = s = nil
    str.strip!
    if str =~ /^(\d?\d):?(\d\d)(\.(\d\d?))?\s*(am?|pm?)?(.*)$/i
      h = $1.to_i
      h += 12 if $5 =~ /^p/i and h <= 12
      m = $2.to_i
      s = $4.to_i or 0
      str = $6
    elsif 'midnight' =~ /^#{str}/i
      h,m,s = [0,0,0]
      str = str[8..-1]
    elsif 'noon' =~ /^#{str}/i
      h,m,s = [12,0,0]
      str = str[4..-1]
    elsif 'teatime' =~ /^#{str}/i
      h,m,s = [16,0,0]
      str = str[8..-1]
    else
      raise ParseError, "Invalid time."
    end
    return [h,m,s,str]
  end

  # date = month-name day | DD.MM.YY[YY] | MM/DD/YY[YY] | MMDDYY[YY] | today | tomorrow
  def self.parse_date(str)
    y = m = d = nil
    str.strip!
    months = %w(january february march april may june july august september october november december)
    if str =~ /^(\d?\d)\.(\d?\d)\.((\d\d\d\d)|(\d?\d))$/
      d = $1.to_i
      m = $2.to_i
      y = $4.to_i or 100*(Time.now.year/100) + $5.to_i
    elsif str =~ /^(\d\d)\/(\d\d)\/((\d\d\d\d)|(\d?\d))$/
      m = $1.to_i
      d = $2.to_i
      y = $4.to_i or 100*(Time.now.year/100) + $5.to_i
    elsif str =~ /^(\d\d)(\d\d)((\d\d\d\d)|(\d?\d))$/
      m = $1.to_i
      d = $2.to_i
      y = $4.to_i or 100*(Time.now.year/100) + $5.to_i
    elsif 'today' =~ /^#{str}$/i
      t = Time.now
      m = t.month
      d = t.day
      y = t.year
    elsif 'tomorrow' =~ /^#{str}$/i
      t = Time.now + 60*60*24
      m = t.month
      d = t.day
      y = t.year
    elsif str =~ /^([a-z]+)\s+(\d+)\s*((\d\d\d\d)|(\d?\d))$/i
      t = Time.now
      d = $2.to_i
      m = months.index $1.downcase
      raise ParseError, "Invalid month" unless m
      m += 1
      if $3
        y = $4.to_i or 100*(t.year/100) + $5.to_i
      else
        y = (t.month < m ? t.year + 1 : t.year)
      end
    elsif str =~ /^$/
      t = Time.now
      y = t.year
      m = t.month
      d = t.day
    else
      raise ParseError, 'Invalid date'
    end
    return [y,m,d]
  end
end

# Copyright (C) 2008  Hans Fugal
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

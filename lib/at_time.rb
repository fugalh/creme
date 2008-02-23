require 'time'

# Parse at-compatible (but better) time specifications
module AtTime
  class ParseError < RuntimeError; end

  # [[CC]YY]MMDDhhmm[.SS]
  def self.parse_posix(str)
    str.strip!
    unless str =~ /((\d\d)?\d\d)?(\d\d)(\d\d)(\d\d)(\d\d)(\.(\d\d))?/
      raise ArgumentError, "Invalid timespec"
    end
    t = Time.now
    if $1
      year = $1
    elsif $2
      year = "#{t.year/100}" + $2
    else
      year = t.year
    end
    seconds = $8 or '00'

    Time.mktime(year,$3,$4,$5,$6,seconds,0)
  end

  # timespec = time [date] | [now] + count units
  def self.parse_timespec(str)
    # [now] + count units
    if str =~ /^\s*(now|(now)?\s*\+\s*(\d+)\s*([a-z]+)?)\s*$/i
      return Time.now if $1 == 'now'

      count = $3.to_i

      # units = seconds | minutes | hours | days | weeks | months | years | 
      # default minutes
      unit = ($4 or 'minutes')
      ary = %w(seconds minutes hours days weeks months years).select{|x| x =~ /^#{unit}/i }
      raise ParseError, "Invalid unit #{unit}" if ary.empty?
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

  # time = [H]H[MM[.SS]] [am|pm] | [H]H[:MM[.SS]] [am|pm] | midnight | noon | teatime
  def self.parse_time(str)
    h = m = s = nil
    str.strip!
    if str =~ /^(\d?\d)(\:?(\d\d)(\.(\d+))?)?\s*(am?|pm?)?(.*)$/i
      h = $1.to_i
      m = s = 0
      if $2
        m = $3.to_i
        s = ($5 ? $5.to_i : 0)
      end
      str = $7 or ""
      h += 12 if $6 =~ /^p/i and h <= 12
    elsif 'midnight' =~ /^#{str}/i
      h,m,s = [0,0,0]
      str = str[$&.size..-1]
    elsif 'noon' =~ /^#{str}/i
      h,m,s = [12,0,0]
      str = str[$&.size..-1]
    elsif 'teatime' =~ /^#{str}/i
      h,m,s = [16,0,0]
      str = str[$&.size..-1]
    else
      raise ParseError, "Invalid time."
    end
    return [h,m,s,str]
  end

  def self.parse_date(str)
    y = m = d = nil
    str.strip!
    months = %w(january february march april may june july august september october november december)
    weekdays = %w(monday tuesday wednesday thursday friday saturday sunday)
    if str =~ /^(\d?\d)\.(\d?\d)\.((\d\d\d\d)|(\d?\d))$/
      d = $1.to_i
      m = $2.to_i
      y = $3.to_i
      y += 100*(Time.now.year/100) if $5
    elsif str =~ /^((\d\d\d\d)|(\d\d))-(\d?\d)-(\d?\d)$/
      d = $5.to_i
      m = $4.to_i
      y = $1.to_i
      y += 100*(Time.now.year/100) if $3
    elsif str =~ /^(\d\d)\/(\d\d)\/((\d\d\d\d)|(\d?\d))$/
      m = $1.to_i
      d = $2.to_i
      y = $3.to_i
      y += 100*(Time.now.year/100) if $5
    elsif str =~ /^(\d\d)(\d\d)((\d\d\d\d)|(\d?\d))$/
      m = $1.to_i
      d = $2.to_i
      y = $3.to_i
      y += 100*(Time.now.year/100) if $5
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
    elsif str =~ /^([a-z]+)\s+(\d+)\s*((\d\d\d\d)|(\d?\d))?$/i
      t = Time.now
      d = $2.to_i
      y = $3
      y4 = $4
      y2 = $5
      m = $1
      ary = months.select{|x| x =~ /^#{m}/i}
      raise ParseError, "Invalid month '#{m}'" if ary.empty?
      raise ParseError, "Ambiguous month '#{m}' (#{ary.inspect})" if ary.size > 1
      m = months.index ary[0]
      m += 1
      if y
        y += 100*(t.year/100) if y2
      else
        y = (t.month < m ? t.year + 1 : t.year)
      end
    elsif str =~ /^([a-z]+)$/i
      wday = $1
      ary = weekdays.select{|x| x =~ /^#{wday}/i}
      raise ParseError, "Invalid weekday '#{wday}'" if ary.empty?
      raise ParseError, "Ambiguous weekday '#{wday}'" if ary.size > 1
      wday = weekdays.index(ary[0]) + 1
      t = Time.now
      days = (wday - t.wday) % 7
      days = 7 if days == 0
      t += days * 60*60*24
      y = t.year
      m = t.month
      d = t.day
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

# vim: nowrap

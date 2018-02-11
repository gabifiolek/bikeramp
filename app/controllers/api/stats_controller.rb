class API::StatsController < ApplicationController
  include ExceptionHandler
  include Response

  def show_weekly
    range = (Date.today-1.week..Date.today)

    data = {
        total_distance: Trip.total_distance(range),
        total_price: Trip.total_price(range)
      }

    json_response(data)
  end

  def show_monthly
    range = (Date.today.beginning_of_month..Date.today.end_of_month)

    @dates = select_occured_dates(range)

    data ||= []

    @dates.each do |date|
      data << {
        day: convert_date(date),
        total_distance: count_total_distance(date),
        avg_ride: count_average_ride(date),
        avg_price: count_average_price(date)
      }
    end
    json_response(data)
  end

  private

    def select_grouped_trips(range)
      Trip.all.select{ |trip| range.cover?(trip.date) }.group_by { |d| d.date }
    end

    def count_total_distance(date)
      distance = Trip.where(date: date).sum(:distance)
      ActionController::Base.helpers.number_to_human(distance, units: {unit: "km"})
    end

    def count_average_ride(date)
      ride = Trip.where(date: date).average(:distance)
      ActionController::Base.helpers.number_to_human(ride, units: {unit: "km"})
    end

    def count_average_price(date)
      price = Trip.where(date: date).average(:price)
      ActionController::Base.helpers.number_to_human(price, units: {unit: "PLN"})
    end

    def select_occured_dates(range)
      select_grouped_trips(range).values.flatten.map(&:date).uniq
    end

    def convert_date(date)
      date.to_time.strftime("%b, #{date.day.ordinalize}")
    end
end

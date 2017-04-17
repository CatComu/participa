namespace :encomu do
  desc "[encomu] Generate orders for collaborations for a specific month"
  task :generate_orders, [:month, :year] => :environment do |t, args|
    args.with_defaults(:month => Date.current.month, :year => Date.current.year)
    date = Time.zone.local(args.year.to_i, args.month.to_i, Rails.application.secrets.orders[:creation_day].to_i)
    Collaboration.find_each do |collaboration|
      collaboration.generate_order date
    end
  end
end

# colaboraciones mensuales/trimestrales/anuales
# - traerse ultima orden
# - generar nueva, si corresponde

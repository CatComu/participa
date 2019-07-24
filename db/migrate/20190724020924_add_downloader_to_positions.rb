class AddDownloaderToPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :positions, :downloader, :boolean, default: false
  end
end

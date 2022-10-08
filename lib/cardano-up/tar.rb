# frozen_string_literal: true

module CardanoUp
  module Tar
    # unzip file to destination directory
    def self.unzip(file, destination)
      FileUtils.mkdir_p(destination)
      Zip::File.open(file) do |zip_file|
        zip_file.each do |f|
          fpath = File.join(destination, f.name)
          zip_file.extract(f, fpath)
        end
      end
    end

    # un-gzips the given IO, returning the
    # decompressed version as a StringIO
    def self.ungzip(tarfile)
      z = Zlib::GzipReader.new(tarfile)
      unzipped = StringIO.new(z.read)
      z.close
      unzipped
    end

    # untars the given IO into the specified
    # directory
    def self.untar(io, destination)
      Gem::Package::TarReader.new io do |tar|
        tar.each do |tarfile|
          destination_file = File.join destination, tarfile.full_name

          if tarfile.directory?
            FileUtils.mkdir_p destination_file
          else
            destination_directory = File.dirname(destination_file)
            FileUtils.mkdir_p destination_directory unless File.directory?(destination_directory)
            File.open destination_file, 'wb' do |f|
              f.print tarfile.read
            end
          end
        end
      end
    end
  end
end

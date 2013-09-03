module TestFtpd

  class FileSystemProvider
    attr_reader :path, :server, :ftp_name, :ftp_size, :ftp_date

    def initialize(path, server)
      @path = path
      @server = server
      @ftp_name = path.split('/').last
      @ftp_name = '/' unless @ftp_name
      @ftp_dir = File.directory?(path)
      @ftp_size = File.size?(path)
      @ftp_size = 0 unless @ftp_size
      @ftp_date = Time.now
      @ftp_date = File.mtime(path) if File.exists?(path)
    end

    def directory?
      @ftp_dir
    end

    def ftp_parent(root = nil)
      return root if root && root.path == path
      path_parts = path.split('/')
      return nil unless path_parts.pop
      return nil if path_parts.size <= 1
      FileSystemProvider.new(path_parts.join('/'), server)
    end

    def ftp_list(filter = nil)
      if filter
        if File.directory?(File.join(path, filter))
          entries = Dir.entries(File.join(path, filter)).map { |name| File.join(filter, name) }
        else
          entries = Dir.glob(File.join(path, filter)).map { |name| File.basename(name) }
        end
      else
        entries = Dir.entries(path)
      end
      entries = entries.reject { |name| %w{. ..}.include?(File.basename(name)) } unless server.config.fetch(:include_dot_folders, false)
      entries.map do |name|
        FileSystemProvider.new(File.join(path, name), server)
      end
    end

    def ftp_create(name, dir = false)
      return FileSystemProvider.new(path + '/' + name, server) unless dir
      Dir.mkdir(path + '/' + name)
      FileSystemProvider.new(path + '/' + name, server)
    rescue
      return false
    end

    def ftp_retrieve(output)
      File.open(path, 'r') { |io| output << io.read }
    end

    def ftp_store(input)
      return false unless File.open(path, 'w') do |f|
        f.write input.read
      end
      @ftp_size = File.size?(path)
      @ftp_date = File.mtime(path) if File.exists?(path)
    end

    def ftp_rename(to_name)
      to_path = File.join(File.dirname(path), to_name)
      FileUtils.mv(path, to_path)
      true
    end

    def ftp_delete(dir = false)
      if dir
        FileUtils.remove_dir(path)
      else
        FileUtils.remove_file(path)
      end
      true
    end

    def self.format_list_entry(file_system_provider)
      raw = (file_system_provider.directory?) ? 'd': '-'
      raw += 'rw-rw-rw- 1 ftp ftp '
      raw += file_system_provider.ftp_size.to_s + ' '
      raw += file_system_provider.ftp_date.strftime('%b %d %H:%M') + ' '
      raw += file_system_provider.ftp_name
      raw += "\r\n"
      raw
    end
  end

end

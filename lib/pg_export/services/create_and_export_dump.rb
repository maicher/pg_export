class PgExport
  module Services
    class CreateAndExportDump
      def initialize(bash_factory:, encryptor:, ftp_repository:)
        @bash_factory, @encryptor, @ftp_repository = bash_factory, encryptor, ftp_repository
      end

      def call(database_name, keep_dumps)
        dump = bash_factory.build_dump(database_name)
        encrypted_dump = encryptor.call(dump)
        ftp_repository.persist(encrypted_dump)
        ftp_repository.remove_old(database_name, keep_dumps)
      end

      private

      attr_reader :bash_factory, :encryptor, :ftp_repository
    end
  end
end

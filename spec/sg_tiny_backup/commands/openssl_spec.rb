# frozen_string_literal: true

RSpec.describe SgTinyBackup::Commands::Openssl do
  it ".decryption_command" do
    expected = "openssl enc -d -aes-256-cbc -pbkdf2 -iter 10000 -pass pass:ENCRYPTION_KEY -in INPUTFILE -out OUTPUTFILE"
    expect(SgTinyBackup::Commands::Openssl.decryption_command).to eq expected
  end
end

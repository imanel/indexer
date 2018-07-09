RSpec.shared_examples 'page verification' do
  before do
    described_class.new.perform(page.id)
    page.reload
  end

  it 'sets h1 to expected value' do
    expect(page.h1).to eq h1
  end
  it 'sets h2 to expected value' do
    expect(page.h2).to eq h2
  end
  it 'sets h3 to expected value' do
    expect(page.h3).to eq h3
  end
  it 'sets links to expected value' do
    expect(page.links).to eq links
  end
  it 'sets parsed to expected value' do
    expect(page.parsed).to eq parsed
  end
  it 'sets error to expected value' do
    expect(page.error).to eq error
  end
end

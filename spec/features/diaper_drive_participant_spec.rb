RSpec.feature "Diaper Drive Participant", type: :feature do
  before do
    sign_in(@user)
  end
  let(:url_prefix) { "/#{@organization.to_param}" }

  context "When a user views the index page" do
    before(:each) do
      @second = create(:diaper_drive_participant, name: "Bcd")
      @first = create(:diaper_drive_participant, name: "Abc")
      @third = create(:diaper_drive_participant, name: "Cde")
      visit url_prefix + '/diaper_drive_participants'
    end
    scenario "the diaper drive participant names are in alphabetical order" do
      expect(page).to have_xpath("//table[@id='diaper_drive_participants']/tbody/tr", count: 3)
      expect(page.find(:xpath, "//table[@id='diaper_drive_participants']/tbody/tr[1]/td[1]")).to have_content(@first.name)
      expect(page.find(:xpath, "//table[@id='diaper_drive_participants']/tbody/tr[3]/td[1]")).to have_content(@third.name)
    end
  end


  scenario "User can create a new diaper drive instance" do
    visit url_prefix + '/diaper_drive_participants/new'
    diaper_drive_participant_traits = attributes_for(:diaper_drive_participant)
    fill_in "Name", with: diaper_drive_participant_traits[:name]
    fill_in "Phone", with: diaper_drive_participant_traits[:phone]

    expect {
      click_button "Create Diaper drive participant"
    }.to change{DiaperDriveParticipant.count}.by(1)

    expect(page.find('.flash.success')).to have_content "added"
  end

  scenario "User can update the contact info for a diaper drive participant" do
    diaper_drive_participant = create(:diaper_drive_participant)
    new_email = 'foo@bar.com'
    visit url_prefix + "/diaper_drive_participants/#{diaper_drive_participant.id}/edit"
    fill_in "Phone", with: ''
    fill_in "Email", with: new_email
    click_button "Update Diaper drive participant"

    expect(page.find('.flash.success')).to have_content "updated"
    expect(page).to have_content(diaper_drive_participant.name)
    expect(page).to have_content(new_email)
  end

  context "When the Diaper Drives have donations associated with them already" do
    before(:each) do
      @ddp = create(:diaper_drive_participant)
      create(:donation, :with_item, created_at: 1.day.ago, item_quantity: 10, source: Donation::SOURCES[:diaper_drive], diaper_drive_participant: @ddp)
      create(:donation, :with_item, created_at: 1.week.ago, item_quantity: 15, source: Donation::SOURCES[:diaper_drive], diaper_drive_participant: @ddp)
    end

    scenario "Existing Diaper Drive Participants show in the #index with some summary stats" do
      visit url_prefix + "/diaper_drive_participants"
      expect(page).to have_xpath("//table[@id='diaper_drive_participants']/tbody/tr/td", text: @ddp.name)
      expect(page).to have_xpath("//table[@id='diaper_drive_participants']/tbody/tr/td", text: "25")
    end

    scenario "Single Diaper Drive Participants show semi-detailed stats about donations from that diaper drive" do
      visit url_prefix + "/diaper_drive_participants/#{@ddp.to_param}"
      expect(page).to have_xpath("//table[@id='diaper_drive_participants']/tbody/tr", count: 2)
    end
  end
end

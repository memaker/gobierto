require 'rails_helper'

RSpec.feature 'Follow place spec' do
  before do
    @user = create_user
  end

  pending 'Logged user follows a place', js: true do
    login_as 'foo@example.com', 'foo123456'

    visit '/budget_lines/santander/2015/1/G/economic'
    expect(page).to have_link('0')
    click_link 'follow_link'
    expect(page).to have_link('1')
  end
end

require 'rails_helper'

RSpec.feature 'Follow place spec' do
  before do
    @user = create_user
  end

  scenario 'Logged user follows a place', js: true do
    login_as 'foo@example.com', 'foo123456'

    visit '/places/santander/2015'
    expect(page).to have_link('0')
    page.execute_script %{ $('#follow_link').click() }
    expect(page).to have_link('1')

    @user.reload
    expect(@user.subscriptions.count).to eq(1)
  end
end

class GroupsUsers < ApplicationRecord
  self.table_name = 'groups_users'
end

class MigrateGroupsToGroupRoles < ActiveRecord::Migration[5.0]
  def up
    add_column :groups_users, :id, :primary_key

    ActiveRecord::Base.transaction do
      # tutors first (the values on the group table)
      Group.find_each do |g|
        user_id = g.user_id || g.tutor_id

        if user_id
          GroupRole.create!(user_id: user_id, group_id: g.id, role: 'tutor')
        end
      end

      # GroupsUsers table
      GroupsUsers.find_each do |gu|
        # tutors first
        user_id = gu.tutor_id || gu.convenor_id

        if user_id.present?
          GroupRole.first_or_create!(user_id: user_id, group_id: gu.group_id, role: 'tutor')
        end

        if gu.student_id.present?
          GroupRole.first_or_create!(user_id: gu.student_id, group_id: gu.group_id, role: 'student')
        end
      end

      # users table
      User.where.not(group_id: nil).find_each do |u|
        GroupRole.create!(user_id: u.id, group_id: u.group_id, role: 'student')
      end
    end
  end

  def down
    GroupRole.delete_all
    remove_column :groups_users, :id, :primary_key
  end
end

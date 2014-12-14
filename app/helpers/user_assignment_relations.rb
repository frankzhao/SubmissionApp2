module UserAssignmentRelations
  def relationship_to(obj)
    if obj.tutors.include?(self) || obj.convenors.include?(self)
      :tutor
    elsif obj.students.include?(self)
      :student
    elsif obj.convenors.include?(self)
      :convener
    elsif self.is_admin?
      :admin
    end
  end
end
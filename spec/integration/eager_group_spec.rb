require 'spec_helper'

RSpec.describe EagerGroup, type: :model do
  describe '.eager_group' do
    context 'has_many' do
      it 'gets Post#approved_comments_count' do
        posts = Post.all.eager_group(:approved_comments_count)
        expect(posts.first.approved_comments_count).to eq 1
        expect(posts.last.approved_comments_count).to eq 2
      end

      it 'gets Post#comments_average_rating' do
        posts = Post.all.eager_group(:comments_average_rating)
        expect(posts.first.comments_average_rating).to eq 3
        expect(posts.last.comments_average_rating).to eq 4
      end

      it 'gets both Post#approved_comments_count and Post#comments_average_rating' do
        posts = Post.all.eager_group(:approved_comments_count, :comments_average_rating)
        expect(posts.first.approved_comments_count).to eq 1
        expect(posts.first.comments_average_rating).to eq 3
        expect(posts.last.approved_comments_count).to eq 2
        expect(posts.last.comments_average_rating).to eq 4
      end
    end

    context 'has_many :through' do
      it 'gets Teacher#students_count' do
        teachers = Teacher.all.eager_group(:students_count)
        expect(teachers.first.students_count).to eq 1
        expect(teachers.last.students_count).to eq 3
      end
    end
  end
end

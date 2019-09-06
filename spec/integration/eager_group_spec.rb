# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EagerGroup, type: :model do
  describe '.eager_group' do
    context 'has_many' do
      it 'gets Post#approved_comments_count' do
        posts = Post.all.eager_group(:approved_comments_count)
        expect(posts[0].approved_comments_count).to eq 1
        expect(posts[1].approved_comments_count).to eq 2
        expect(posts[2].approved_comments_count).to eq 0
      end

      it 'gets Post#comments_average_rating' do
        posts = Post.all.eager_group(:comments_average_rating)
        expect(posts[0].comments_average_rating).to eq 3
        expect(posts[1].comments_average_rating).to eq 4
        expect(posts[2].comments_average_rating).to eq 0
      end

      it 'gets both Post#approved_comments_count and Post#comments_average_rating' do
        posts =
          Post.all.eager_group(
            :approved_comments_count,
            :comments_average_rating
          )
        expect(posts[0].approved_comments_count).to eq 1
        expect(posts[0].comments_average_rating).to eq 3
        expect(posts[1].approved_comments_count).to eq 2
        expect(posts[1].comments_average_rating).to eq 4
        expect(posts[2].approved_comments_count).to eq 0
        expect(posts[2].comments_average_rating).to eq 0
      end

      it 'gets Post#comments_average_rating_by_author' do
        students = Student.all
        posts =
          Post.all.eager_group(
            [:comments_average_rating_by_author, students[0], true]
          )
        expect(posts[0].comments_average_rating_by_author).to eq 4.5
        expect(posts[1].comments_average_rating_by_author).to eq 3
      end

      it 'gets Post#comments_average_rating from users' do
        users =
          User.includes(:posts).eager_group(posts: :comments_average_rating)
        expect(users[0].posts[0].comments_average_rating).to eq 3
        expect(users[1].posts[0].comments_average_rating).to eq 4
      end

      it 'gets Post#comments_average_rating from users' do
        users =
          User.includes(:posts).eager_group(posts: :comments_average_rating)
        expect(users[0].posts[0].comments_average_rating).to eq 3
        expect(users[1].posts[0].comments_average_rating).to eq 4
      end

      it 'gets Post#first_comment and Post#last_comment' do
        posts = Post.all.eager_group(:first_comment, :last_comment)
        expect(posts[0].first_comment).to eq posts[0].comments.first
        expect(posts[1].first_comment).to eq posts[1].comments.first
        expect(posts[2].first_comment).to be_nil
        expect(posts[0].last_comment).to eq posts[0].comments.last
        expect(posts[1].last_comment).to eq posts[1].comments.last
        expect(posts[2].last_comment).to be_nil
      end

      it 'gets Post#comments_average_rating and Post#comments_average_rating from users' do
        users =
          User.includes(:posts).eager_group(
            posts: %i[approved_comments_count comments_average_rating]
          )
        expect(users[0].posts[0].approved_comments_count).to eq 1
        expect(users[0].posts[0].comments_average_rating).to eq 3
        expect(users[1].posts[0].approved_comments_count).to eq 2
        expect(users[1].posts[0].comments_average_rating).to eq 4
      end

      it 'does not raise error when association is empty' do
        Teacher.includes(:homeworks).eager_group(homeworks: :students_count)
          .to_a
      end
    end

    context 'has_many :through' do
      it 'gets Teacher#students_count' do
        teachers = Teacher.all.eager_group(:students_count)
        expect(teachers[0].students_count).to eq 1
        expect(teachers[1].students_count).to eq 3
        expect(teachers[2].students_count).to eq 0
      end
    end

    context 'has_many :as, has_many :through' do
      it 'gets Student#posts_count' do
        students = Student.all.eager_group(:posts_count)
        expect(students[0].posts_count).to eq 2
        expect(students[1].posts_count).to eq 1
        expect(students[2].posts_count).to eq 0
      end
    end
  end

  describe '.preload_eager_group' do
    context 'Cache query result' do
      it 'eager_group result cached' do
        posts = Post.all.eager_group(:approved_comments_count)
        post = posts[0]
        object_id1 =
          post.instance_variable_get('@approved_comments_count').object_id
        object_id2 = post.approved_comments_count.object_id
        object_id3 = post.approved_comments_count.object_id
        expect(object_id1).to eq object_id2
        expect(object_id1).to eq object_id3
      end

      it 'eager_group result cached if arguments given' do
        students = Student.all
        posts =
          Post.all.eager_group(
            [:comments_average_rating_by_author, students[0], true]
          )
        post = posts[0]
        object_id1 =
          post.instance_variable_get('@comments_average_rating_by_author')
            .object_id
        object_id2 = post.comments_average_rating_by_author.object_id
        object_id3 = post.comments_average_rating_by_author.object_id
        expect(object_id1).to eq object_id2
        expect(object_id1).to eq object_id3
      end

      it 'magic method result cached' do
        post = Post.first
        object_id1 = post.approved_comments_count.object_id
        object_id2 = post.approved_comments_count.object_id
        expect(object_id1).to eq object_id2
      end

      it 'magic method not cache if arguments given' do
        students = Student.all
        posts = Post.all
        object_id1 =
          posts[0].comments_average_rating_by_author(students[0], true)
            .object_id
        object_id2 =
          posts[0].comments_average_rating_by_author(students[0], true)
            .object_id
        expect(object_id1).not_to eq object_id2
      end
    end

    context 'has_many' do
      it 'gets Post#approved_comments_count' do
        posts = Post.all
        expect(posts[0].approved_comments_count).to eq 1
        expect(posts[1].approved_comments_count).to eq 2
      end

      it 'gets Post#comments_average_rating' do
        posts = Post.all
        expect(posts[0].comments_average_rating).to eq 3
        expect(posts[1].comments_average_rating).to eq 4
      end

      it 'gets both Post#approved_comments_count and Post#comments_average_rating' do
        posts = Post.all
        expect(posts[0].approved_comments_count).to eq 1
        expect(posts[0].comments_average_rating).to eq 3
        expect(posts[1].approved_comments_count).to eq 2
        expect(posts[1].comments_average_rating).to eq 4
        expect(posts[2].approved_comments_count).to eq 0
      end

      it 'gets Post#comments_average_rating_by_author' do
        students = Student.all
        posts = Post.all
        expect(
          posts[0].comments_average_rating_by_author(students[0], true)
        ).to eq 4.5
        expect(
          posts[1].comments_average_rating_by_author(students[0], true)
        ).to eq 3
      end
    end

    context 'has_many :through' do
      it 'gets Teacher#students_count' do
        teachers = Teacher.all
        expect(teachers[0].students_count).to eq 1
        expect(teachers[1].students_count).to eq 3
        expect(teachers[2].students_count).to eq 0
      end
    end

    context 'has_many :as, has_many :through' do
      it 'gets Student#posts_count' do
        students = Student.all
        expect(students[0].posts_count).to eq 2
        expect(students[1].posts_count).to eq 1
        expect(students[2].posts_count).to eq 0
      end
    end
  end
end

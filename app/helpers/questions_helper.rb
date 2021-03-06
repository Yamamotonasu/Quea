module QuestionsHelper

  # 質問のインスタンスを第一引数に、第二引数に回答番号を渡すと回答者の都道府県別の回答人数を得られる (例) {"大阪府": 2, "東京都", 1}
  def count_prefecture(question, i)
    user_id = Answer.where(answer_result: question.num_one, target: true).pluck(:answer_id) if i == 1
    user_id = Answer.where(answer_result: question.num_two, target: true).pluck(:answer_id) if i == 2
    user_id = Answer.where(answer_result: question.num_three, target: true).pluck(:answer_id) if i == 3
    user_id = Answer.where(answer_result: question.num_four, target: true).pluck(:answer_id) if i == 4

    User.where(id: user_id).pluck(:prefecture).group_by(&:itself).map{ |k, v| [k, v.count] }.to_h.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
  end

  def graph_judgement(question, one, two, three, four)
    if (one + two + three + four) == 0
      "まだ回答がありません。"
    elsif question.blank?
      pie_chart [[question.num_one, one], [question.num_two, two]], donut: true
    elsif question.num_three.present?
      pie_chart [[question.num_one, one], [question.num_two, two], [question.num_three, three]], donut: true
    else
      pie_chart [[question.num_one, one], [question.num_two, two], [question.num_three, three], [question.num_four, four]], donut: true
    end
  end

  def column_judgement(question, one, two, three, four)
    if (one + two + three + four) == 0
      return
    elsif question.blank?
      bar_chart [[question.num_one, one], [question.num_two, two]]
    elsif question.num_three.present?
      bar_chart [[question.num_one, one], [question.num_two, two], [question.num_three, three]]
    else
      bar_chart [[question.num_one, one], [question.num_two, two], [question.num_three, three], [question.num_four, four]]
    end
  end

  # 質問のインスタンスと回答番号を返すと[10台,20台,30台,40台,50台,60台,70台,80歳以上]の値の数で配列を返す
  def count_age(question, i)
    user = case i
           when 1
             Answer.where(answer_result: question.num_one, target: true).pluck(:answer_id)
           when 2
             Answer.where(answer_result: question.num_two, target: true).pluck(:answer_id)
           when 3
             Answer.where(answer_result: question.num_three, target: true).pluck(:answer_id)
           when 4
             Answer.where(answer_result: question.num_four, target: true).pluck(:answer_id)
           end

    age = User.where(id: user).pluck(:age)

    [age.select{ |x| x.to_i.between?(10,19) }.count,
     age.select{ |x| x.to_i.between?(20,29) }.count,
     age.select{ |x| x.to_i.between?(30,39) }.count,
     age.select{ |x| x.to_i.between?(40,49) }.count,
     age.select{ |x| x.to_i.between?(50,59) }.count,
     age.select{ |x| x.to_i.between?(60,69) }.count,
     age.select{ |x| x.to_i.between?(70,79) }.count,
     age.select{ |x| x.to_i >= 80 }.count]
  end

  # 質問のインスタンスと回答番号を引数に取ると性別の配列が帰ってくる (例) ["男","女","男","男"....]
  def count_sex(question, i)
    user = case i
           when 1
             Answer.where(answer_result: question.num_one, target: true).pluck(:answer_id)
           when 2
             Answer.where(answer_result: question.num_two, target: true).pluck(:answer_id)
           when 3
             Answer.where(answer_result: question.num_three, target: true).pluck(:answer_id)
           when 4
             Answer.where(answer_result: question.num_four, target: true).pluck(:answer_id)
           end
    sex = User.where(id: user).pluck(:sex)
    sex_group_graph(sex)
  end

  # 年齢層の配列を渡すとチャートを返す
  def age_group_graph(age_group)
    pie_chart [["10台", age_group[0]], ["20台", age_group[1]], ["30台", age_group[2]], ["40台", age_group[3]], ["50台", age_group[4]], ["60台", age_group[5]], ["70台", age_group[6]], ["80歳以上", age_group[7]]]
  end

  # 回答者の性別の配列を渡すとチャートを返す
  def sex_group_graph(sex)
    man = sex.count("男")
    women = sex.count("女")
    [man, women]
    # pie_chart [["男性", man], ["女性", women]] #何故かpie_chartが帰ってこない
  end
end
require_relative 'environment.rb'

class OkielaTasks
  include Environment

  def board
    @board ||= get('members/me/boards').select { |e| e['name'] == 'OkieLa Tasks' }.first
  end

  def lists
    @list ||= get("boards/#{board['id']}/lists").inject({}) { |h, e| h.merge(e['name'].downcase => e) }
  end

  def cards(list)
    return [] unless lists[list]
    get("lists/#{lists[list]['id']}/cards")
  end

  def find_card(list_name, card_name)
    list = cards(list_name)
    list.select { |e| e['name'].downcase == card_name.downcase }.first
  end

  def create_card(card_name, due: nil, list_name: 'new', extra_option: {})
    card = find_card(list_name, card_name)
    return "Card existed!" if card
    due = due ? due.parse_datetime.strftime('%m/%d/%Y 11:59:59') : ''
    extra_option[:idLabels] = get_labels(extra_option[:labels]) rescue ''
    params = {
      name: card_name,
      idList: lists[list_name]['id'],
      due: due
    }.merge!(extra_option)

    post('cards', params)
  end

  def update_card(card_name, due: nil, list_name: 'new', extra_option: {})
    card = find_card(list_name, card_name)
    return "Card doesn't existed!" unless card
    due = due ? due.parse_datetime.strftime('%m/%d/%Y 11:59:59') : ''
    extra_option[:idLabels] = get_labels(extra_option[:labels]) rescue ''
    params = {
      name: card_name,
      idList: lists[list_name]['id'],
      due: due,
    }.merge!(extra_option)

    put("cards/#{card['id']}", params)
  end

  def create_tasks(start_date: nil, end_date: nil, extra_option: {})
    start_date = DateTime.parse(start_date, '%d/%m/%Y')
    end_date = DateTime.parse(end_date, '%d/%m/%Y')
    (start_date..end_date).each do |date|
      card_name = date.strftime('#%d%m%Y')
      card = create_card(card_name, due: date.strftime('%d/%m/%Y'), extra_option: extra_option)
    end
  end

  def update_tasks(start_date: nil, end_date: nil, extra_option: {})
    start_date = DateTime.parse(start_date, '%d/%m/%Y')
    end_date = DateTime.parse(end_date, '%d/%m/%Y')
    (start_date..end_date).map do |date|
      card_name = date.strftime('#%d%m%Y')
      card = update_card(card_name, due: date.strftime('%d/%m/%Y'), extra_option: extra_option)
    end
  end

  def all_labels
    @labels ||= get("boards/#{board['id']}/labels?fields=all&limit=50").inject({}) { |h, e| h.merge(e['name'].downcase => e) }
  end

  def get_labels(labels)
    labels.map do |label|
      all_labels[label]['id'] rescue nil
    end.compact.join(',')
  end

  def process
    create_tasks(start_date: '30/07/2019', end_date: '30/08/2020', extra_option: {labels: %w(okiela medium)})
    # update_tasks(start_date: '19/1/2019', end_date: '01/03/2019', extra_option: {labels: %w(okiela medium)})
  end
end

OkielaTasks.new.process

require_relative 'environment.rb'

class OkielaTasks
  include Environment

  def board
    @board ||= get('members/me/boards').select { |e| e['name'] == 'OkieLa Tasks' }.first
  end

  def lists
    @lists ||= get("boards/#{board['id']}/lists").inject({}) { |h, e| h.merge(e['name'].downcase => e) }
  end

  def cards(list)
    return [] unless lists[list]

    get("lists/#{lists[list]['id']}/cards")
  end

  def find_card(list_name, card_name)
    list = cards(list_name)
    list.select { |e| e['name'].downcase == card_name.downcase }.first
  end

  def create_card(card_name, due: nil, list_name: 'new', extra_options: {})
    card = find_card(list_name, card_name)
    return 'Card existed!' if card

    params = build_card_params(card_name, due: due, list_name: list_name, extra_options: extra_options)
    post('cards', params)
  end

  def update_card(card_name, due: nil, list_name: 'new', extra_options: {})
    card = find_card(list_name, card_name)
    return "Card doesn't existed!" unless card

    params = build_card_params(card_name, due: due, list_name: list_name, extra_options: extra_options)
    put("cards/#{card['id']}", params)
    add_check_list_to_card(card, extra_options: extra_options)
  end

  def build_card_params(card_name, due: nil, list_name: 'new', extra_options: {})
    due = due ? due.parse_datetime.strftime('%m/%d/%Y 11:59:59') : ''
    extra_options[:idLabels] = labels(extra_options[:labels]) rescue ''
    {
      name: card_name,
      idList: lists[list_name]['id'],
      due: due,
    }.merge!(extra_options)
  end

  def add_check_list_to_card(card, extra_options: {})
    card_id = card['id']
    return if extra_options.dig(:check_lists).nil? || card_id.nil?

    check_list_names = get("cards/#{card_id}/checklists").map { |e| e.dig('name') }

    extra_options.dig(:check_lists).each do |check_list_name|
      next if check_list_names.include?(check_list_name)

      post("cards/#{card_id}/checklists", name: 'Todo')
    end
  end

  def create_tasks(start_date: nil, end_date: nil, extra_options: {})
    start_date = DateTime.parse(start_date, '%d/%m/%Y')
    end_date = DateTime.parse(end_date, '%d/%m/%Y')
    (start_date..end_date).each do |date|
      card_name = date.strftime('#%d%m%Y')
      puts "Creating #{card_name}"
      create_card(card_name, due: date.strftime('%d/%m/%Y'), extra_options: extra_options)
    end
  end

  def update_tasks(start_date: nil, end_date: nil, extra_options: {})
    start_date = DateTime.parse(start_date, '%d/%m/%Y')
    end_date = DateTime.parse(end_date, '%d/%m/%Y')
    (start_date..end_date).map do |date|
      card_name = date.strftime('#%d%m%Y')
      puts "Updating #{card_name}"
      update_card(card_name, due: date.strftime('%d/%m/%Y'), extra_options: extra_options)
    end
  end

  def all_labels
    @all_labels ||= get("boards/#{board['id']}/labels?fields=all&limit=50").inject({}) { |h, e| h.merge(e['name'].downcase => e) }
  end

  def labels(labels)
    labels.map do |label|
      all_labels[label]['id'] rescue nil
    end.compact.join(',')
  end

  def process
    # create_tasks(start_date: '30/07/2019', end_date: '30/08/2020', extra_options: { labels: %w[okiela medium] })
    update_tasks(
      start_date: '02/09/2019',
      end_date: '04/09/2020',
      extra_options: {
        labels: %w[okiela medium],
        check_lists: %w[Todo],
      }
    )
    # update_tasks(start_date: '19/1/2019', end_date: '01/03/2019', extra_options: { labels: %w[okiela medium] })
  end
end

OkielaTasks.new.process

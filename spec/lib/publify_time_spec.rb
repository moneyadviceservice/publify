describe PublifyTime do
  describe 'delta' do
    it 'returns nil when nil year, nil month and nil day' do
      expect(PublifyTime.delta).to be_nil
    end

    it 'returns year when year given' do
      start_at = Time.zone.local(2009, 1, 1, 0, 0, 0)
      end_at   = start_at.end_of_year
      expect(PublifyTime.delta(2009)).to eq(start_at..end_at)
    end

    it 'returns year and month when year and month given' do
      start_at = Time.zone.local(2009, 10, 1, 0, 0, 0)
      end_at   = start_at.end_of_month
      expect(PublifyTime.delta(2009, 10)).to eq(start_at..end_at)
    end

    it 'returns year, month and day when year, month and day given' do
      start_at = Time.zone.local(2009, 10, 23, 0, 0, 0)
      end_at   = start_at.end_of_day
      expect(PublifyTime.delta(2009, 10, 23)).to eq(start_at..end_at)
    end

    it 'returns year, when year given type string' do
      start_at = Time.zone.local(2009, 1, 1, 0, 0, 0)
      end_at   = start_at.end_of_year
      expect(PublifyTime.delta('2009')).to eq(start_at..end_at)
    end

    it 'returns year and month when year and month given type string' do
      start_at = Time.zone.local(2009, 9, 1, 0, 0, 0)
      end_at   = start_at.end_of_month
      expect(PublifyTime.delta('2009', '09')).to eq(start_at..end_at)
    end

    it 'returns year, month and day when year, month and day given type string' do
      start_at = Time.zone.local(2009, 1, 1, 0, 0, 0)
      end_at   = start_at.end_of_day
      expect(PublifyTime.delta('2009', '01', '01')).to eq(start_at..end_at)
    end

  end

  describe 'delta_like' do
    it 'given year' do
      start_at = Time.zone.local(2013, 1, 1, 0, 0, 0)
      end_at   = start_at.end_of_year
      expect(PublifyTime.delta_like('2013')).to eq(start_at..end_at)
    end

    it 'given year month' do
      start_at = Time.zone.local(2013, 9, 1, 0, 0, 0)
      end_at   = start_at.end_of_month
      expect(PublifyTime.delta_like('2013-09')).to eq(start_at..end_at)
    end

    it 'given year month day' do
      start_at = Time.zone.local(2013, 8, 1, 0, 0, 0)
      end_at   = start_at.end_of_day
      expect(PublifyTime.delta_like('2013-08-01')).to eq(start_at..end_at)
    end

  end
end

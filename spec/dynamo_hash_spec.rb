describe DynamoHash do
  subject { dynamo_hash }

  context 'when get_item' do
    before do
      query(<<-EOS)
        INSERT INTO #{TEST_TABLE_NAME} (id, str, num, strs, nums)
        VALUES ('myid', 'foo', 123, ('bar', 'zoo', 'baz'), (4, 5, 6))
      EOS

      query(<<-EOS)
        INSERT INTO #{TEST_TABLE_NAME} (id, str, num, strs, nums)
        VALUES ('myid2', 'FOO', 321, ('BAR', 'ZOO', 'BAZ'), (400, 500, 600))
      EOS
    end

    it do
      expect(subject['myid']).to eq(
        'id'   => 'myid',
        'str'  => 'foo',
        'num'  => BigDecimal.new(123),
        'strs' => Set['bar', 'zoo', 'baz'],
        'nums' => Set[*[4, 5, 6].map {|i| BigDecimal.new(i)}]
      )
    end
  end

  context 'when put_item' do
    it do
     subject['myid'] = {
        'str'  => 'foo',
        'num'  => 123,
        'strs' => Set['bar', 'zoo', 'baz'],
        'nums' => Set[4, 5, 6]
      }

     subject['myid2'] = {
        'str'  => 'FOO',
        'num'  => 321,
        'strs' => Set['BAR', 'ZOO', 'BAZ'],
        'nums' => Set[400, 500, 600]
      }

      expect(select_all).to match_array [
        {'id'=>'myid',  'num'=>123, 'nums'=>[4, 5, 6],       'str'=>'foo', 'strs'=>['bar', 'zoo', 'baz']},
        {'id'=>'myid2', 'num'=>321, 'nums'=>[400, 500, 600], 'str'=>'FOO', 'strs'=>['BAR', 'ZOO', 'BAZ']}
      ]
    end
  end

  context 'when delete_item' do
    before do
      query(<<-EOS)
        INSERT INTO #{TEST_TABLE_NAME} (id, str, num, strs, nums)
        VALUES ('myid', 'foo', 123, ('bar', 'zoo', 'baz'), (4, 5, 6))
      EOS

      query(<<-EOS)
        INSERT INTO #{TEST_TABLE_NAME} (id, str, num, strs, nums)
        VALUES ('myid2', 'FOO', 321, ('BAR', 'ZOO', 'BAZ'), (400, 500, 600))
      EOS
    end

    it do
      subject.delete('myid')

      expect(select_all).to match_array [
        {'id'=>'myid2', 'num'=>321, 'nums'=>[400, 500, 600], 'str'=>'FOO', 'strs'=>['BAR', 'ZOO', 'BAZ']}
      ]
    end
  end
end

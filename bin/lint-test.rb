# frozen_string_literal: true

require 'test/unit'
require './bin/lint'

# Test case for the GTN linter
class Gtn::Linter::Test < Test::Unit::TestCase
  include Gtn::Linter

  def test_fix_notoc
    text = "a\n{: .no_toc}\nasdf".split "\n"
    result = Gtn::Linter.fix_notoc(text)

    assert_equal(result[0]['location']['range']['start']['line'], 2)
    assert_equal(result[0]['location']['range']['start']['column'], 1)

    assert_equal(result[0]['location']['range']['end']['line'], 3)
    assert_equal(result[0]['location']['range']['end']['column'], 1)
  end

  def test_fix_broken_link
    text = "a\n{% link does-not-exist.md %}\nasdf".split "\n"
    #          123456789
    result = Gtn::Linter.check_bad_link(text)

    assert_equal(result[0]['message'], 'The linked file (`does-not-exist.md`) could not be found.')

    assert_equal(result[0]['location']['range']['start']['line'], 2)
    assert_equal(result[0]['location']['range']['start']['column'], 1)

    assert_equal(result[0]['location']['range']['end']['line'], 2)
    assert_equal(result[0]['location']['range']['end']['column'], 28)
  end

  def test_youtube
    text = "a\n<iframe .. youtube.com ... </iframe>x\nasdf".split "\n"
    result = Gtn::Linter.youtube_bad(text)

    assert_equal(result[0]['location']['range']['start']['line'], 2)
    assert_equal(result[0]['location']['range']['start']['column'], 1)

    assert_equal(result[0]['location']['range']['end']['line'], 2)
    assert_equal(result[0]['location']['range']['end']['column'], text[1].length)
  end

  def test_external_gtn_link
    url = 'https://training.galaxyproject.org/training-material/topics/admin/tutorials/ansible-galaxy/tutorial.html'
    text = "a\na[test](#{url})b\nasdf".split "\n"
    #          1234567890
    result = Gtn::Linter.link_gtn_tutorial_external(text)

    assert_equal(result[0]['location']['range']['start']['line'], 2)
    assert_equal(result[0]['location']['range']['start']['column'], 9)

    assert_equal(result[0]['location']['range']['end']['line'], 2)
    assert_equal(result[0]['location']['range']['end']['column'], 9 + url.length)

    assert_equal(result[0]['suggestions'][0]['text'],
                 '{% link topics/admin/tutorials/ansible-galaxy/tutorial.md %}')
    assert_equal(result[0]['suggestions'][0]['range']['start']['line'], 2)
    assert_equal(result[0]['suggestions'][0]['range']['start']['column'], 9)
    assert_equal(result[0]['suggestions'][0]['range']['end']['line'], 2)
    assert_equal(result[0]['suggestions'][0]['range']['end']['column'], 9 + url.length)
  end

  def test_external_gtn_link_slides
    url = 'https://training.galaxyproject.org/training-material/topics/admin/tutorials/ansible-galaxy/slides.html'
    text = "a\na[test](#{url})b\nasdf".split "\n"
    #          1234567890
    result = Gtn::Linter.link_gtn_slides_external(text)

    assert_equal(result[0]['location']['range']['start']['line'], 2)
    assert_equal(result[0]['location']['range']['start']['column'], 9)

    assert_equal(result[0]['location']['range']['end']['line'], 2)
    assert_equal(result[0]['location']['range']['end']['column'], 9 + url.length)

    assert_equal(result[0]['suggestions'][0]['text'],
                 '{% link topics/admin/tutorials/ansible-galaxy/slides.html %}')
    assert_equal(result[0]['suggestions'][0]['range']['start']['line'], 2)
    assert_equal(result[0]['suggestions'][0]['range']['start']['column'], 9)
    assert_equal(result[0]['suggestions'][0]['range']['end']['line'], 2)
    assert_equal(result[0]['suggestions'][0]['range']['end']['column'], 9 + url.length)
  end

  def test_doi
    text = "a\nfrom [Pedro Larrañaga, 2006](https://doi.org/10.1093/bib/bbk007).\nasdf".split "\n"
    #          123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
    result = Gtn::Linter.check_dois(text)

    assert_equal(result[0]['location']['range']['start']['line'], 2)
    assert_equal(result[0]['location']['range']['start']['column'], 6)

    assert_equal(result[0]['location']['range']['end']['line'], 2)
    assert_equal(result[0]['location']['range']['end']['column'], 64 + 2) # Inexplicable.

    assert_equal(result[0]['suggestions'][0]['text'], '{% cite ... %}')
    assert_equal(result[0]['suggestions'][0]['range']['start']['line'], 2)
    assert_equal(result[0]['suggestions'][0]['range']['start']['column'], 6)
    assert_equal(result[0]['suggestions'][0]['range']['end']['line'], 2)
    assert_equal(result[0]['suggestions'][0]['range']['end']['column'], 64 + 2)

    text = "a\nfrom [Pedro Larrañaga, 2006](https://doi.org/10.5281/zenodo.10238184212).\nasdf".split "\n"
    #          12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
    result = Gtn::Linter.check_dois(text)
    assert_equal(result.length, 0)
  end

  def testnew_title_
    [
      %w[tip Tip],
      %w[details Details],
      %w[hands_on Hands-on]
    ].each do |key, key_text|
      text = "a\n> ### {% icon #{key} %} #{key_text}: Blah\n> #{key_text} text\n{: .#{key}}".split "\n"
      #          12345678901234567890123456789012345678901234567890
      result = Gtn::Linter.new_more_accessible_boxes(text)

      assert_equal(result[0]['location']['range']['start']['line'], 2)
      assert_equal(result[0]['location']['range']['start']['column'], 3)

      assert_equal(result[0]['location']['range']['end']['line'], 2)
      assert_equal(result[0]['location']['range']['end']['column'], 24 + key.length + key_text.length + 1)

      k2 = key.gsub(/_/, '-')
      assert_equal(result[0]['suggestions'][0]['text'], "<#{k2}-title>Blah</#{k2}-title>")
    end

    # assert_equal(result[0]['suggestions'][0]['range']['start']['line'], 2)
    # assert_equal(result[0]['suggestions'][0]['range']['start']['column'], 9)
    # assert_equal(result[0]['suggestions'][0]['range']['end']['line'], 2)
    # assert_equal(result[0]['suggestions'][0]['range']['end']['column'], 9 + url.length)
  end
end

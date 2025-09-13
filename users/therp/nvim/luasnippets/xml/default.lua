local luasnip = require('luasnip')
local c = luasnip.choice_node
local i = luasnip.insert_node
local s = luasnip.snippet
local t = luasnip.text_node


XML_HEADER = '<?xml version="1.0" encoding="utf-8" ?>'


return {
	s('data-file', {
		t({
			XML_HEADER,
			'<odoo>',
			'    ',
		}),
		i(1, '...'),
		t({'', '</odoo>'}),
	}),

	s('field', {
		t('<field name="'),
		i(1, 'name'),
		t('" />')
	}),

	s('xpath', {
		t('<xpath expr="'),
		i(1, '//path/to/element'),
		t('" position="'),
		c(2, {
			t('before'),
			t('after'),
			t('inside'),
			t('replace'),
		}),
		t({'">', '    '}),
		i(3, '...'),
		t({'', '</xpath>'}),
	}),

	s('view-inherit', {
		t('<record id="'),
		i(1, 'view_id'),
		t({
			'" model="ir.ui.view">',
			'    <field name="model">'
		}),
		i(2, 'model.name'),
		t({
			'</field>',
			'    <field name="inherit_id" ref="'
		}),
		i(3, 'module.view_name'),
		t({
			'" />',
			'    <field name="arch" type="xml">',
			'        '
		}),
		i(4, '...'),
		t({
			'',
			'    </field>',
			'</record>'
		}),
	}),
}

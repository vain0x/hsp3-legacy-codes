var Footy2 =
  {
    RGB:
      function(r, g, b)
      {
        var byte = function(x) { return x & 0xFF; };
        return byte(r) | (byte(g) << 8) | (byte(b) << 16);
      },

    PERMIT_LEVEL:
      function(x)
      {
        return 1 << x;
      },

    Consts =
      {
        // EmpMode:
        EMP_INVALIDITY    : 0,
        EMP_WORD          : 1,
        EMP_LINE_AFTER    : 2,
        EMP_LINE_BETWEEN  : 3,
        EMP_MULTI_BETWEEN : 4,

        // EmpType:
        EMPFLAG_BOLD   : 0x00000001,
        EMPFLAG_NON_CS : 0x00000002,
        EMPFLAG_HEAD   : 0x00000004,

        // IndependentFlags:
        EMP_IND_PARENTHESIS      :  0x00000001,
        EMP_IND_BRACE            :  0x00000002,
        EMP_IND_ANGLE_BRACKET    :  0x00000004,
        EMP_IND_SQUARE_BRACKET   :  0x00000008,
        EMP_IND_QUOTATION        :  0x00000010,
        EMP_IND_UNDERBAR         :  0x00000020,
        EMP_IND_OPERATORS        :  0x00000040,
        EMP_IND_OTHER_ASCII_SIGN :  0x00000080,
        EMP_IND_NUMBER           :  0x00000100,
        EMP_IND_CAPITAL_ALPHABET :  0x00000200,
        EMP_IND_SMALL_ALPHABET   :  0x00000400,
        EMP_IND_SPACE            :  0x00001000,
        EMP_IND_FULL_SPACE       :  0x00002000,
        EMP_IND_TAB              :  0x00004000,
        EMP_IND_JAPANESE         :  0x00010000,
        EMP_IND_KOREAN           :  0x00020000,
        EMP_IND_EASTUROPE        :  0x00040000,
        EMP_IND_OTHERS           :  0x80000000,
        EMP_IND_ASCII_SIGN       :  0x000000FF,
        EMP_IND_ASCII_LETTER     :  0x00000F00,
        EMP_IND_BLANKS           :  0x0000F000,
        EMP_IND_OTHER_CHARSETS   :  0xFFFF0000,
        EMP_IND_ALLOW_ALL        :  0xFFFFFFFF
      },

    Emphasis:
      function()
      {
        this.list = [];
        this.config =
          {
            type          : Footy2.Consts.EMP_WORD,
            flags         : 0,
            level         : 0,
            permission    : 0x00000001,
            independence  : Footy2.Consts.EMP_IND_ALLOW_ALL,
            color         : 0x000000
          };

        this.add =
          function(s1, s2)
          {
            this.list.push(
              {
                s1: s1,
                s2: s2,
                type          : this.config.type,
                flags         : this.config.flags,
                level         : this.config.level,
                permission    : this.config.permission,
                independence  : this.config.independence,
                color         : this.config.color
              });
          };

        var emph_to_string =
          function(emph)
          {
            return (
              [
                emph.s1,
                emph.s2,
                emph.type,
                emph.flags,
                emph.level,
                emph.permission,
                emph.independence,
                emph.color
              ].join("\t")
              );
          };

        this.toString =
          function()
          {
            return this.list.map(emph_to_string).join("\n");
          };
      }
  };

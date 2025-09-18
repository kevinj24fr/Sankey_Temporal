# install.packages(c("readxl","dplyr","ggplot2","ggalluvial")) # if needed
library(readxl)
library(dplyr)
library(ggplot2)
library(ggalluvial)

# 1) Read
df <- readxl::read_excel("Data/Sankey Plot for kev.xlsx", sheet = "Sheet1")

# 2) Recode (exact legend)
df2 <- df %>% dplyr::transmute(Gender = as.factor(Gender),
                               before = dplyr::recode(as.character(Before_SIH),
                                                      "1000" = "Full capacity",
                                                      "555"  = "Voluntary reduction (non-physical)",
                                                      "666"  = "Unemployed",
                                                      .default = NA_character_),
                               after = dplyr::recode(as.character(After_Symptoms),
                                                     "100" = "Full capacity",
                                                     "99"  = "Adapted but full capacity",
                                                     "80"  = "Reduced to 50–80%",
                                                     "20"  = "Reduced to 20–50%",
                                                     "0"   = "Unable to work / sick leave",
                                                     .default = NA_character_),
                               last  = dplyr::recode(as.character(Status_FollowUp),
                                                     "100" = "Full capacity",
                                                     "99"  = "Adapted but full capacity",
                                                     "80"  = "Reduced to 50–80%",
                                                     "20"  = "Reduced to 20–50%",
                                                     "0"   = "Unable to work / sick leave",
                                                     .default = NA_character_)) %>%
  dplyr::filter(!is.na(Gender), !is.na(before), !is.na(after), !is.na(last)) %>%
  dplyr::mutate(before = base::factor(before, levels = c("Full capacity","Voluntary reduction (non-physical)","Unemployed")),
                after = base::factor(after, levels = c("Full capacity",
                                                       "Adapted but full capacity",
                                                       "Reduced to 50–80%",
                                                       "Reduced to 20–50%",
                                                       "Unable to work / sick leave")),
                last = base::factor(last, levels = base::levels(after)))

# 3) Aggregate paths and convert counts -> percentages within each Gender
paths <- df2 %>% dplyr::count(Gender, before, after, last, name = "Freq") %>%
  dplyr::group_by(Gender) %>%
  dplyr::mutate(pct = 100 * Freq / base::sum(Freq)) %>%   # normalize within gender
  dplyr::ungroup() %>%
  dplyr::mutate(flow_id = dplyr::row_number())

# 4) Lodes form (keeps pct)
lodes <- ggalluvial::to_lodes_form(data  = paths,
                                   axes  = c("before", "after", "last"),
                                   id    = "flow_id",
                                   key   = "stage",
                                   value = "state")

# 5) Plot percentages (y = pct), faceted by Gender

p <- ggplot(lodes, aes(x = stage, stratum = state, alluvium = flow_id, y = pct, fill = state)) +
  ggalluvial::geom_flow(stat = "alluvium",
                        lode.guidance = "forward",
                        alpha = 0.6,
                        width = 0.6) +
  ggalluvial::geom_stratum(width = 0.6, color = "white", size = 0.6) +
  scale_x_discrete(labels = c("Before SIH", "After Symptom Start", "Last FU")) +
  labs(x = NULL, y = "Patients (%)",
       title = "Work capacity transitions",
       fill = "Work capacity state") +
  ggplot2::theme_bw(base_size = 12) +
  ggplot2::theme(legend.position = "right")+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

print(p)

ggsave("Plots/sankey_sih_perc.pdf", p, width = 8, height = 5, dpi = 300)

# 5) Plot percentages (y = pct), integrated
p <- ggplot(lodes, aes(x = stage, stratum = state, alluvium = flow_id, y = pct, fill = state)) +
  ggalluvial::geom_flow(stat = "alluvium",
                        lode.guidance = "forward",
                        alpha = 0.6,
                        width = 0.6) +
  ggalluvial::geom_stratum(width = 0.6, color = "white", size = 0.5) +
  scale_x_discrete(labels = c("Before SIH", "After Symptom Start", "Last FU")) +
  labs(x = NULL, y = "Patients (%)",
       title = "Work capacity transitions, by Gender",
       fill = "Work capacity state") +
  ggplot2::facet_wrap(~ Gender) +
  ggplot2::theme_bw(base_size = 12) +
  ggplot2::theme(legend.position = "right")+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

print(p)
ggsave("Plots/sankey_sih_perc_gender.pdf", p, width = 8, height = 5, dpi = 300)
